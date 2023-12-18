from faker import Faker
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from dataclasses import dataclass
from datetime import date
import random


PURCHASES = 1000


def generate_purchases_and_productsales():
    fake = Faker()
    connection_string = "DSN=asd;Trusted_Connection=yes;"
    connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})

    engine = create_engine(connection_url)

    all_products = []
    all_employees = []
    all_clients = []
    all_cars = []
    with engine.connect() as s:
        q = text('select product_id, list_price, weight from products')
        all_products = s.execute(q).all()
        q = text('select employee_id from employees')
        for asd in s.execute(q):
            all_employees.extend(asd)
        q = text('select client_id from clients')
        for asd in s.execute(q):
            all_clients.extend(asd)
        q = text('select model_id, price, weight from car_models')
        all_cars = s.execute(q).all()

    with engine.connect() as s:
        for _ in range(PURCHASES // 3 * 2):
            products_in_purchase = random.randrange(1, 6)
            client = random.choice(all_clients)
            employee = random.choice(all_employees)
            cur_products = {}
            while len(cur_products) < products_in_purchase:
                cur_products[random.choice(all_products)] = random.randrange(1, 6)

            sum = 0
            sw = 0
            for ((prod_id, price, weight), amount) in cur_products.items():
                sum += price * amount
                sw += weight * amount
            
            q = text('insert into purchases(total_cost, total_weight, client_id, employee_id) values\
                    (:s, :w, :client, :emp)').bindparams(s=sum, w=sw, client=client, emp=employee)
            s.execute(q)
            s.commit()
            q = text(f"select ident_current('purchases')")
            purch_id = s.execute(q).all()[0][0]
            for ((prod_id, price, _), amount) in cur_products.items():
                q = text('insert into product_sales(purchase_id, product_id, amount) values\
                        (:purch_id, :product_id, :amount)').\
                            bindparams(purch_id=purch_id, product_id=prod_id, amount=amount)
                s.execute(q)
                s.commit()
        for _ in range(PURCHASES - (PURCHASES // 3 * 2)):
            cars_in_purchase = random.randrange(1, 4)
            client = random.choice(all_clients)
            employee = random.choice(all_employees)
            cur_cars = {}
            while len(cur_cars) < cars_in_purchase:
                cur_cars[random.choice(all_cars)] = random.randrange(1, 6)
            sum = 0
            sw = 0
            for ((car_model, price, weight), amount) in cur_cars.items():
                sum += price * amount
                sw += amount * weight
            q = text('insert into purchases(total_cost, total_weight, client_id, employee_id) values\
                    (:s, :w, :client, :emp)').bindparams(s=sum, w=sw, client=client, emp=employee)
            s.execute(q)
            s.commit()
            q = text(f"select ident_current('purchases')")
            purch_id = s.execute(q).all()[0][0]
            for ((car_model, price, _), amount) in cur_cars.items():
                q = text('insert into car_sales(purchase_id, model_id, amount) values\
                        (:purch_id, :car_id, :amount)').\
                            bindparams(purch_id=purch_id, car_id=car_model, amount=amount)
                s.execute(q)
                s.commit()
            
        s.commit()


if __name__ == '__main__':
    generate_purchases_and_productsales()