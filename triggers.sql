
create or alter trigger add_at_to_order
on products
after update
as
if (update(amount_left))
	begin try
		begin transaction
			insert into to_order 
			select  inserted.product_id, inserted.vendor_code, providers.provider_id, inserted.provider_cost
			from inserted
			join providers
			on inserted.provider_id = providers.provider_id
			left join to_order
			on inserted.product_id = to_order.product_id
			where to_order.product_id is null and inserted.amount_left = 5
		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch


select * from to_order
select * from products
update products
set amount_left = 5
where product_id = 1


create or alter trigger on_delete_sale
on product_sales
after delete
as
	begin try
		begin transaction
			if (exists( select product_sales.product_id
							from product_sales
							join deleted
							on deleted.purchase_id = product_sales.purchase_id)) 
							--если не один, то обновл€ем цену и вес заказа, а затем стоимость доставки
				begin
				update purchases
				set purchases.total_cost = purchases.total_cost - products.list_price * product_sales.amount,
					total_weight = purchases.total_weight - products.weight * product_sales.amount
				from purchases
				join deleted
				on deleted.purchase_id = purchases.purchase_id
				join products
				on deleted.product_id = products.product_id
				join product_sales
				on deleted.product_id = product_sales.product_id

				declare @delivery_id int;
				declare cur cursor local fast_forward for 
					select deliveries.delivery_id
					from deliveries
					join purchases
					on purchases.purchase_id = deliveries.delivery_id
					join deleted
					on deleted.purchase_id = purchases.purchase_id
	
				open cur
				fetch cur into @delivery_id
				close cur
				deallocate cur

				execute dbo.find_delivery_cost_and_weight @delivery_id --процедура обновит коэффицент веса и стоимость доставки
				end
		
			else -- если товар в заказе один, то удал€ем заказ, доставка удалитс€ каскадно
				begin
				delete purchases
				from purchases
				join deleted 
				on deleted.purchase_id = purchases.purchase_id
				end
		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch

select count(product_id), purchase_id
from product_sales
group by purchase_id
having count(product_id) = 1

select product_id from product_sales where purchase_id = 45

delete from product_sales
where product_id = 494 and purchase_id = 45

select * from purchases
where purchases.purchase_id = 45

create or alter trigger count_del_price
on deliveries
after insert, update
as
	declare @delivery_id int
	declare cur cursor local fast_forward for
		select delivery_id
		from inserted

	open cur
	fetch cur into @delivery_id
	close cur
	deallocate cur
	execute dbo.find_delivery_cost_and_weight @delivery_id
select * from deliveries
