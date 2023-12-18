create or alter function get_client_info
(@client_id int)
returns table
as 
return
	select client_id, name, surname, email, phone_number, gender, birth_date,
	clients.address_id, country, province, city, street, house, postal_code  from clients
	join addresses 
	on addresses.address_id = clients.address_id
	where client_id = @client_id

----------
create or alter function get_delivery_address(@delivery_id int)
returns table 

as 

return 

select country, province, city, street, house, postal_code
from deliveries
join purchases
on deliveries.purchase_id = purchases.purchase_id
join clients
on clients.client_id = purchases.client_id
join addresses
on clients.address_id = addresses.address_id
where delivery_id = @delivery_id

----------
create or alter function get_purchase_content(@purchase_id int)
returns @t table(id int, type varchar(10), amount int)
as
	begin
		insert into @t(id, type, amount)
		(select product_id as id, 'product', amount from product_sales where @purchase_id = purchase_id)

		insert into @t(id, type, amount)
		(select model_id as id, 'car', amount from car_sales where @purchase_id = purchase_id)
		return
	end
