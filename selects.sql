select * from categories
select * from providers
select * from clients
select * from employees
select * from addresses
select * from products

select providers.provider_id, company_name
from providers
join products as pr
on pr.provider_id = providers.provider_id

select * from car_models

select * from purchases
select * from product_sales

select product_sales.purchase_id, product_sales.product_id, list_price, amount, total_cost from purchases
join product_sales
on product_sales.purchase_id = purchases.purchase_id
join products 
on products.product_id = product_sales.product_id

select * from car_details

select * from deliveries