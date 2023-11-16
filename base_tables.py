from faker import Faker
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from dataclasses import dataclass
from datetime import date
import random


EMPLOYEES = 10 
CLIENTS = 10
PROVIDERS = 10


fake = Faker()
connection_string = "DSN=asd;Trusted_Connection=yes;"
connection_url = URL.create("mssql+pyodbc", query={"odbc_connect": connection_string})
# это пиздец, майкрософт контора пидорасов

engine = create_engine(connection_url)


@dataclass
class Client:
    name: str
    surname: str
    email: str
    phone_number: str
    address: dict
    gender: str
    birth_date: date


def generate_cli(persons: list):
    for _ in range(CLIENTS):
        p = fake.profile()
        name, surname = fake.word(), fake.word() 
        email = p['mail']
        bd = p['birthdate']
        sex = p['sex']
        phone_number = '+' + str(random.randrange(10 ** 10, 10 ** 15))
        address = {
            "country": fake.word(),
            "province": fake.word(),
            "city": fake.word(),
            "street": fake.word(),
            "house": random.randrange(1, 100),
            "postal_code": random.randrange(100000, 1000000),
        }
        persons.append(Client(name=name, surname=surname, birth_date=bd, email=email, phone_number=phone_number, address=address, gender=sex))


@dataclass
class Employee:
    name: str
    surname: str
    birth_date: date
    phone_number: str
    salary: float
    job: str


def generate_emp(persons: list):
    for _ in range(EMPLOYEES):
        p = fake.profile()
        name, surname = fake.word().replace("'", '`'), fake.word().replace("'", '`')
        bd = p['birthdate']
        job = p['job'].replace("'", '`')
        phone_number = '+' + str(random.randrange(10 ** 10, 10 ** 15))
        sal = (random.randrange(1, 100000))  / 3
        f = Employee(name=name, surname=surname, birth_date=bd, job=job, phone_number=phone_number, salary=sal)
        persons.append(f)


@dataclass
class Provider:
    address: dict
    company_name: str
    email: str
    phone_number: str    


def generate_pro(providers: list):
    for _ in range(PROVIDERS):
        name = fake.word()
        email = fake.email()
        phone_number = '+' + str(random.randrange(10 ** 10, 10 ** 15))
        address = {
            "country": fake.word(),
            "province": fake.word(),
            "city": fake.word(),
            "street": fake.word(),
            "house": random.randrange(1, 100),
            "postal_code": random.randrange(100000, 1000000),
        }
        providers.append(Provider(company_name=name, email=email, address=address, phone_number=phone_number))
 

def generate_base_tables():
    with engine.connect() as sess:
        clients = []
        employees = []
        providers = []
        categories = ['cars', 'accessories', 'tires', 'rimes', 'details']
        generate_emp(employees)
        generate_cli(clients)
        generate_pro(providers)
        for cat in categories:
            q = text(f"insert into categories(name) values ('{cat}')")
            sess.execute(q)
        sess.commit()
        for provider in providers:
            country, province, city, street, house, postal_code = provider.address.values()
            q = text(f"insert into addresses(country, province, city, street, house, postal_code)\
                      values ('{country}', '{province}', '{city}', '{street}', '{house}', '{postal_code}')")
            sess.execute(q)
            sess.commit()
            q = text(f"select scope_identity()")
            address_id = sess.execute(q).all()[0][0]
            q = text(f"insert into providers(address_id, company_name, email, phone_number) values\
                     ('{address_id}', '{provider.company_name}', '{provider.email}', '{provider.phone_number}')")
            sess.execute(q)
            sess.commit()
        
        for cli in clients:
            country, province, city, street, house, postal_code = cli.address.values()
            q = text(f"insert into addresses(country, province, city, street, house, postal_code)\
                      values ('{country}', '{province}', '{city}', '{street}', '{house}', '{postal_code}')")
            sess.execute(q)
            sess.commit()
            q = text(f"select scope_identity()")
            address_id = sess.execute(q).all()[0][0]
            q = text(f'''insert into clients(name, surname, email, phone_number, address_id, gender, birth_date) values
            ('{cli.name}', '{cli.surname}', '{cli.email}', '{cli.phone_number}', '{address_id}', '{cli.gender}', '{str(cli.birth_date)}')''')
            sess.execute(q)
            sess.commit()

        for emp in employees:
            q = text(f'''insert into employees(name, surname, birth_date, phone_number, salary, job) values
                     ('{emp.name}', '{emp.surname}', '{str(emp.birth_date)}', '{emp.phone_number}', '{emp.salary}', '{emp.job}')''')
            sess.execute(q)
            sess.commit()


if __name__ == '__main__':
    generate_base_tables()
