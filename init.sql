create table categories (
	category_id int identity(1, 1) primary key,
	name varchar(64) not null unique
)

create table employees (
	employee_id int identity(1, 1) primary key,
	name varchar(64) not null,
	surname varchar(64) not null,
	birth_date date not null,
	phone_number varchar(16),
	salary money not null,
	job varchar(64) not null,
)

create table addresses (
	address_id int identity(1, 1) primary key,
	country varchar(128) not null, 
	province varchar(128) not null,
	city varchar(128) not null,
	street varchar(128) not null,
	house varchar(128) not null,
	postal_code varchar(128) not null
)

create table providers (
	provider_id int identity(1, 1) primary key,
	address_id int not null,
	company_name varchar(128) not null,
	email varchar(64) not null,
	phone_number varchar(16) not null

	constraint FK_provider_address foreign key (address_id) references addresses(address_id)
	on delete cascade
	on update cascade
)


create table products (
	product_id int identity(1, 1) primary key,
	vendor_code varchar(128) not null,
	name varchar(128) not null,
	category_id int not null,
	provider_cost money not null,
	list_price money not null,
	description varchar(1024) default null,
	provider_id int,
	amount_left int not null

	constraint FK_product_category foreign key (category_id) references categories(category_id)
	on delete cascade
	on update cascade,
	constraint FK_product_provider foreign key (provider_id) references providers(provider_id)
	on delete cascade
	on update cascade
)

create table car_models (
	model_id int identity(1, 1) primary key,
	provider_id int,
	model_name varchar(64) not null,
	carcass_type varchar(64) not null,
	horse_powers int not null,
	price money not null, 

	constraint FK_car_model_provider foreign key (provider_id) references providers(provider_id)
	on delete cascade
	on update cascade
)

create table car_details (
	model_id int,
	product_id int,

	primary key(model_id, product_id),
	constraint FK_car_detail_model foreign key (model_id) references car_models(model_id)
	on delete cascade
	on update cascade,
	constraint FK_car_detail_product foreign key (product_id) references products(product_id)
	on delete no action
	on update no action
)

create table clients (
	client_id int identity(1, 1) primary key,
	name varchar(32) not null,
	surname varchar(32) not null,
	email varchar(128) not null,
	phone_number varchar(16) not null,
	address_id int default null,
	gender varchar(128) default null,
	birth_date date default null

	constraint FK_client_address foreign key (address_id) references addresses(address_id)
	on delete cascade
	on update cascade
)

create table purchases (
	purchase_id int identity(1, 1) primary key,
	total_cost money not null,
	client_id int,
	employee_id int

	constraint FK_purchase_client foreign key (client_id) references clients(client_id)
	on delete cascade
	on update cascade,
	constraint FK_purchase_employee foreign key (employee_id) references employees(employee_id)
	on delete cascade
	on update cascade
)

create table product_sales (
	purchase_id int,
	product_id int,
	amount int not null,

	constraint FK_sale_purchase foreign key (purchase_id) references purchases(purchase_id)
	on delete cascade
	on update cascade,
	constraint FK_sale_product foreign key (product_id) references products(product_id)
	on delete no action
	on update no action
)

create table deliveries (
	delivery_id int identity(1, 1) primary key,
	purchase_id int,
	address_id int default null,
	delivery_date date not null,
	status varchar(16) not null,
	delivery_type varchar(64) not null default 'pickup',
	delivery_cost money not null default 0

	constraint FK_delivery_purchase foreign key (purchase_id) references purchases(purchase_id)
	on delete cascade
	on update cascade,
	constraint FK_delivery_address foreign key (address_id) references addresses(address_id)
	on delete no action
	on update no action
)
