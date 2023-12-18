create or alter view profit_by_products_view(product_id, provider_id, amount_sold, total_profit)
as
	select  products_amounts.product_id, products.provider_id, products_amounts.amount as amount_sold,
			products_amounts.amount * (products.list_price - products.provider_cost) as total_profit
	from
		(select sum(amount) as amount, product_id
		from product_sales
		group by product_id) as products_amounts
	join products
	on products.product_id = products_amounts.product_id

select * from profit_by_products_view
order by -total_profit / amount_sold

create or alter view delivery_info_view
(client_full_name, email, phone_number, address, delivery_date, cost, delivery_type)
as
select name + ' ' + surname as client_full_name, email, phone_number, 
country + ' ' + province + ' ' + city + ' ' + street + ' ' + house + ' ' + postal_code as address,
delivery_date, cost, description
from deliveries
join purchases
on purchases.purchase_id = deliveries.purchase_id
join clients
on clients.client_id = purchases.client_id
join addresses
on addresses.address_id = clients.address_id
join delivery_methods
on deliveries.delivery_method_id = delivery_methods.method_id
where status = 'in delivery'

select * from delivery_info_view

create or alter view car_models_view(model_name, carcass_type, horse_powers, weight, price)
as 
select model_name, carcass_type, horse_powers, weight, price
from car_models

select * from car_models_view
