import MySQLdb as mdb

db = mdb.connect(host="localhost", user="root", password="", database="deductions")
cursor = db.cursor()


class Database:
    @classmethod
    def get(cls):
        pass

    @classmethod
    def get_employees(cls):
        query = "SELECT id, name FROM employee"
        cursor.execute(query)
        return cursor.fetchall()
