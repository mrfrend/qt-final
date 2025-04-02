import MySQLdb as mdb

db = mdb.connect(host="localhost", user="root", password="", database="deducations")
cursor = db.cursor()


class Database:
    @classmethod
    def get(cls):
        pass
