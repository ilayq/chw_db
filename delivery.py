from faker import Faker
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from datetime import datetime
from purchases_sales import PURCHASES
import random


DELIVERIES = PURCHASES // 4 + 1


def generate_deliveries():
    fake = Faker()
    connection_string = "DSN=asd;Trusted_Connection=yes;"
    connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})

    engine = create_engine(connection_url)
    all_purch = []
    all_cli = []

    with engine.connect() as s:
        q = text('select purchase_id from purchases')
        res = s.execute(q)
        for asd in res:
            all_purch.extend(asd)
        q = text('select client_id from clients')
        res = s.execute(q)
        for asd in res:
            all_cli.extend(asd)
        
        cur_date = datetime.now().date()
        for _ in range(DELIVERIES):
            purch_id = random.choice(all_purch)
            del_date = datetime.strptime(str(fake.date()), "%Y-%m-%d").date()
            if del_date < cur_date:
                status = 'delivered'
            else:
                status = 'in delivery'
            delivery_type = random.choice(['car', 'ship', 'airplane', 'pickup'])
            if delivery_type == 'pickup':
                delivery_cost = 0
            else:
                delivery_cost = random.randrange(100, 10000)

            #create address
            q = text('select clients.address_id from purchases\
                    join clients\
                    on purchases.client_id = clients.client_id\
                    where purchases.purchase_id = :purch_id').bindparams(purch_id=purch_id)
            address_id = s.execute(q).all()[0][0]
            q = text('insert into deliveries(purchase_id, address_id, delivery_date, status, delivery_type, delivery_cost) values\
                     (:purch_id, :address_id, :delivery_date, :status, :delivery_type, :delivery_cost)').\
                    bindparams(purch_id=purch_id, address_id=address_id, delivery_date=str(del_date),
                                status=status, delivery_type=delivery_type, delivery_cost=delivery_cost)
            s.execute(q)
        s.commit()
    # address = {
    #         "country": fake.word(),
    #         "province": fake.word(),
    #         "city": fake.word(),
    #         "street": fake.word(),
    #         "house": random.randrange(1, 100),
    #         "postal_code": random.randrange(100000, 1000000),
    # }


if __name__ == '__main__':
    generate_deliveries()
