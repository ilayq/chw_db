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
            q = text('select total_weight from purchases where purchase_id = :p_id').bindparams(p_id=purch_id)
            weight = s.execute(q).first()[0]
            if del_date < cur_date:
                status = 'delivered'
            else:
                status = 'in delivery'
            q = text("select destination_type_id from destination_types")
            types = []
            for t in s.execute(q):
                types.extend(t)
            dest_type_id = random.choice(types)
            q = text('select weight_coefficient_id from weight_coefficients where lower_threshold<= :w and :w <upper_threshold').bindparams(w=weight)
            w_coef = s.execute(q).first()[0]
            q = text('select method_id from delivery_methods')
            meths = []
            for m in s.execute(q):
                meths.extend(m)
            del_meth = random.choice(meths)

            q = text('insert into deliveries(purchase_id, delivery_date, status, destination_type_id, delivery_method_id) values\
                     (:purch_id, :delivery_date, :status, :dest_type_id, :del_meth)').\
                    bindparams(purch_id=purch_id, delivery_date=str(del_date),
                                status=status, dest_type_id=dest_type_id, del_meth=del_meth)
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
