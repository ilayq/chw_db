from base_tables import generate_base_tables
from products import generate_products, generate_car_details
from purchases_sales import generate_purchases_and_productsales
from delivery import generate_deliveries

from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL


connection_string = "DSN=asd;Trusted_Connection=yes;"
connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})

engine = create_engine(connection_url)


if __name__ == '__main__':
    generate_base_tables()
    generate_products()
    with open('cars.sql') as f:
        with engine.connect() as s:
            s.execute(text(f.read()))
            s.commit()
    with open('coef.sql') as f:
        with engine.connect() as s:
            s.execute(text(f.read()))
            s.commit()
    with open('del_methods.sql') as f:
        with engine.connect() as s:
            s.execute(text(f.read()))
            s.commit()
    with open('dest_types.sql') as f:
        with engine.connect() as s:
            s.execute(text(f.read()))
            s.commit()
    generate_purchases_and_productsales()
    generate_car_details()
    generate_deliveries()