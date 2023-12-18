from faker import Faker
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from dataclasses import dataclass
from datetime import date
import random


PRODUCTS = 1000
CAR_DETAILS = PRODUCTS // 3 + 1


fake = Faker()
connection_string = "DSN=asd;Trusted_Connection=yes;"
connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})

engine = create_engine(connection_url)


def generate_products():

    providers = []
    categories = []

    with engine.connect() as s:
        q = text('select provider_id from providers')
        res = s.execute(q)
        for pr in res:
            providers.extend(pr)
        q = text('select category_id from categories')
        res = s.execute(q)
        for pr in res:
            categories.extend(pr)

    with engine.connect() as s:
        for _ in range(PRODUCTS):
            provider = random.choice(providers)
            category = random.choice(categories)
            vendor_code = fake.ean13()
            name = fake.word()
            provider_cost = random.randrange(100000) / 3
            weight = random.randrange(300) / 3
            list_price = random.randrange(3 * int(provider_cost), 6 * int(provider_cost)) / 3
            description = ' '.join(fake.words(nb=20))
            amount_left = random.randrange(5, 15)

            q = text(f'''insert into products(vendor_code, name, category_id, weight, provider_cost, list_price, description, provider_id, amount_left) values\
                    (:vendor_code, :name, :category_id, :weight, :provider_cost, :list_price, :description, :provider_id, :amount_left)''').\
                    bindparams(vendor_code=vendor_code, category_id=category, name=name, provider_cost=provider_cost, list_price=list_price, description=description,
                    amount_left=amount_left, provider_id=provider, weight=weight)
            s.execute(q)
        s.commit()


def generate_car_details():
    with engine.connect() as s:
        q = text('select model_id, product_id from car_models cross join products')
        res = s.execute(q).all()
        c = 0
        while c < CAR_DETAILS:
            model_id, product_id = random.choice(res)
            q = text('insert into car_details(model_id, product_id) values (:model_id, :product_id)').\
                bindparams(model_id=model_id, product_id=product_id)
            try:
                s.execute(q)
                c += 1
            except:
                pass
        s.commit()
    


if __name__ == '__main__':
    generate_products()
    generate_car_details()
