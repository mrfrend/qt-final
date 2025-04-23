import MySQLdb as mdb

db = mdb.connect(host="localhost", user="root", password="", database="deductions")
cursor = db.cursor()


class Database:

    @classmethod
    def get_employees(cls):
        query = "SELECT id, name FROM employee"
        cursor.execute(query)
        return cursor.fetchall()

    @classmethod
    def get_type_operations(cls):
        query = "SELECT name FROM type_operation"
        cursor.execute(query)
        return [row[0] for row in cursor.fetchall()]

    @classmethod
    def get_employee_info(cls, employee_id: int):
        query = "SELECT * FROM employee WHERE id = %s"
        cursor.execute(query, (employee_id,))
        return cursor.fetchone()

    @classmethod
    def get_type_deductions(cls):
        query = "SELECT name FROM type_deduction"
        cursor.execute(query)
        return [row[0] for row in cursor.fetchall()]

    @classmethod
    def get_amount_of_children(cls, employee_id: int):
        query = """
                SELECT COUNT(child.id)
                FROM employee
                LEFT JOIN child ON employee.id = %s
                AND child.parent_id = %s
                WHERE TIMESTAMPDIFF(YEAR, child.birth_date, CURDATE()) < 18
            """
        cursor.execute(query, (employee_id, employee_id))
        return cursor.fetchone()[0]

    @classmethod
    def call_calculate_procedure(
        cls, employee_id: int, operation_id: int, selected_priviliges: list[bool]
    ) -> float | None:
        try:

            num_params = (
                2 + len(selected_priviliges) + 1
            )  # employee_id, operation_id, privileges, result
            cursor.callproc(
                "CalculateTaxBaseOrNDFL",
                (employee_id, operation_id, *selected_priviliges, 0),
            )

            cursor.execute(f"SELECT @_CalculateTaxBaseOrNDFL_{num_params - 1}")
            calculation = cursor.fetchone()[0]
            print(f"Calculation result: {calculation}")
            return calculation
        except Exception as e:
            print(f"Error in call_calculate_procedure: {e}")
            return None

    @classmethod
    def call_write_procedure(
        cls, employee_id: int, operation_id: int, selected_priviliges: list[bool]
    ):
        try:
            cursor.callproc(
                "WriteTaxBaseOrNDFL",
                (employee_id, operation_id, *selected_priviliges),
            )
            db.commit()
        except Exception as e:
            print(e)
            db.rollback()

    @classmethod
    def get_priviliges_by_employee_id(cls, employee_id: int) -> dict[str, bool]:
        try:
            employee_info = cls.get_employee_info(employee_id)
            is_veteran = int(employee_info[3])

            amount_of_children = cls.get_amount_of_children(employee_id)
            priviliges = cls.get_type_deductions()
            priviligy_access = dict(
                zip(priviliges, map(bool, [is_veteran, amount_of_children]))
            )

            return priviligy_access

        except Exception as e:
            print(e)
            return None
