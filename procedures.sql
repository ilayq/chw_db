create or alter procedure find_delivery_cost_and_weight(@delivery_id int)
as 
begin
	begin try
		begin transaction
			declare @weight float
			declare @wc_id int
			declare @w_coef float

			declare cur cursor local fast_forward for --находим вес заказа из purchases
				select purchases.total_weight
				from deliveries
				join purchases
				on deliveries.delivery_id = purchases.purchase_id
				where delivery_id = @delivery_id
			open cur
			fetch cur into @weight
			close cur
			deallocate cur

			declare cur cursor local fast_forward for -- находим коэффицент веса и id
				select weight_coefficient_id, coefficient from weight_coefficients
				where lower_threshold <=  @weight and @weight < upper_threshold
			open cur
			fetch cur into @wc_id, @w_coef
			close cur
			deallocate cur

			update deliveries
			set weight_coefficient_id = @wc_id
			where deliveries.delivery_id = @delivery_id -- обновляем id в deliveries

			declare cur cursor local fast_forward for --находим остальные коэффиценты
				select delivery_methods.coefficient, destination_types.cost
				from deliveries
				join delivery_methods 
				on deliveries.delivery_method_id = delivery_methods.method_id
				join destination_types	
				on deliveries.destination_type_id = destination_types.destination_type_id
				where deliveries.delivery_id = @delivery_id
			open cur
			declare @mc float, @price float
			fetch cur into @mc, @price
			close cur
			deallocate cur

			update deliveries -- обновляем значение в таблице
			set cost = @price * @mc * @w_coef
			where deliveries.delivery_id = @delivery_id
			commit transaction
			return @price * @mc * @w_coef
	end try
	begin catch
		rollback;
		throw;
	end catch
end


create or alter procedure make_sail_on_least_sold_products(@sale_size_percents float, @amount_of_products int)
as

begin
	begin try
		begin transaction
			update products
			set products.list_price = products.list_price * (1 - @sale_size_percents / 100)
			from products
			join (  select product_id
					from dbo.profit_by_products_view
					order by amount_sold
					offset(0) rows fetch next(@amount_of_products) rows only) as sale_products
			on products.product_id = sale_products.product_id
		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch
end

execute make_sail_on_least_sold_products 10, 20
select products.product_id, list_price, amount_sold
from dbo.profit_by_products_view
join products
on dbo.profit_by_products_view.product_id = products.product_id
order by amount_sold
offset(0) rows fetch next(20) rows only


create or alter procedure order_product(@product int, @amount int)
as

begin
	begin try
		begin transaction
			
			delete to_order
			from to_order
			join products
			on to_order.product_id = products.product_id
			where @product = to_order.product_id and amount_left + @amount > 5

			update products 
			set amount_left += @amount
			where @product = product_id

		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch
end

create or alter procedure buy_product(@product_id int, @amount int, @client_id int, @employee_id int = 1)
as 
begin 
	if (not exists(select * from products where product_id = @product_id and @amount <= amount_left)
		or not exists(select * from clients where client_id = @client_id))
		throw 50001, 'Amount left is lower than you want to buy or invalid client_id', 1;
	begin try
		begin transaction
			declare @price_for_one money;
			declare @weight_for_one float;
			declare cur cursor local fast_forward for 
				select list_price, weight from products
				where product_id = @product_id
			open cur
			fetch cur into  @price_for_one, @weight_for_one;
			close cur;
			deallocate cur;
			insert into purchases(total_cost, total_weight, client_id, employee_id, purchase_date) values 
			(@price_for_one * @amount, @weight_for_one * @amount, @client_id, @employee_id, getdate());
			declare @p_id int = ident_current('purchases');
			insert into product_sales(purchase_id, product_id, amount) values (@p_id, @product_id, @amount)
			update products
			set amount_left -= @amount
			where @product_id = product_id
		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch
end