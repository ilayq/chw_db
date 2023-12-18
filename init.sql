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
	unique(country, province, city, street, house)
)

create table providers (
	provider_id int identity(1, 1) primary key,
	address_id int not null,
	company_name varchar(128) not null unique,
	email varchar(64) not null unique,
	phone_number varchar(16) not null unique

	constraint FK_provider_address foreign key (address_id) references addresses(address_id)
	on delete cascade
	on update cascade
)


create table products (
	product_id int identity(1, 1) primary key,
	vendor_code varchar(128) not null unique,
	name varchar(128) not null,
	category_id int not null,
	weight float default 0,
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
	model_name varchar(64) not null unique,
	carcass_type varchar(64) not null,
	horse_powers int not null,
	weight float not null,
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
	email varchar(128) not null unique,
	phone_number varchar(16) not null unique,
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
	total_weight float default 0,
	client_id int,
	employee_id int,
	purchase_date date default getdate()

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

	primary key(purchase_id, product_id),
	constraint FK_sale_purchase foreign key (purchase_id) references purchases(purchase_id)
	on delete cascade
	on update cascade,
	constraint FK_sale_product foreign key (product_id) references products(product_id)
	on delete no action
	on update no action
)

create table car_sales (
	purchase_id int,
	model_id int,
	amount int not null,

	primary key(purchase_id, model_id),
	constraint FK_carsale_purchase foreign key (purchase_id) references purchases(purchase_id)
	on delete cascade
	on update cascade,
	constraint FK_sale_car foreign key (model_id) references car_models(model_id)
	on delete no action
	on update no action
)

create table delivery_methods (
	method_id int identity(1, 1) primary key,
	coefficient float not null,
	description varchar(100) not null
)

/* another country, another region, another city, in city, pickup */
create table destination_types (
	destination_type_id int identity(1, 1) primary key,
	cost money not null default 0,
	description varchar(100) not null
)

create table weight_coefficients (
	weight_coefficient_id int identity(1, 1) primary key, 
	lower_threshold float not null,
	upper_threshold float not null,
	coefficient float not null
)


create table deliveries (
	delivery_id int identity(1, 1) primary key,
	purchase_id int,
	delivery_date date not null,
	status varchar(16) not null,
	destination_type_id int,
	delivery_method_id int,
	weight_coefficient_id int default null,
	cost money default null

	constraint FK_delivery_weight_coef_id foreign key (weight_coefficient_id) references weight_coefficients(weight_coefficient_id)
	on delete cascade
	on update cascade,
	constraint FK_delivery_dest_type foreign key (destination_type_id) references destination_types(destination_type_id)
	on delete cascade
	on update cascade,
	constraint FK_delivery_method foreign key (delivery_method_id) references delivery_methods(method_id)
	on delete no action
	on update no action,
	constraint FK_delivery_purchase foreign key (purchase_id) references purchases(purchase_id)
	on delete cascade
	on update cascade
)

create table to_order (
	--(product_id, vendor_code, provider_id, provider_cost, email, phone_number)
	product_id int references products(product_id),
	vendor_code varchar(128) not null,
	provider_id int references providers(provider_id),
	provider_cost money not null,
)
