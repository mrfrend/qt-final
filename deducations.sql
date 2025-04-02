CREATE DATABASE deductions;

use deductions;

CREATE TABLE employee (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    salary DECIMAL(8, 2),
    is_veteran BOOLEAN DEFAULT FALSE
);

CREATE TABLE child (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    parent_id INT NOT NULL,
    FOREIGN KEY (parent_id) REFERENCES employee(id)
);

CREATE TABLE type_deduction (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    deduction_amount INT NOT NULL
);


CREATE TABLE type_operation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE accrual (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    date_accrual DATE DEFAULT (CURRENT_DATE),
    type_operation_id INT NULL,
    amount DECIMAL(8, 2) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employee(id),
    FOREIGN KEY (type_operation_id) REFERENCES type_operation(id)
);

CREATE TABLE proc_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    type_operation_id INT NOT NULL,
    amount DECIMAL(8, 2) NOT NULL,
    operation_datetime DATETIME DEFAULT (CURRENT_TIMESTAMP),
    FOREIGN KEY(employee_id) REFERENCES employee(id),
    FOREIGN KEY(type_operation_id) REFERENCES type_operation(id)
);

DELIMITER //
CREATE FUNCTION CalculateTaxBase(p_employee_id INT)
RETURNS DECIMAL(8, 2)
BEGIN
    DECLARE privilege_percent INT;
    DECLARE child_amount INT;
    DECLARE employee_salary DECIMAL(8, 2);
    DECLARE is_veteran BOOLEAN DEFAULT FALSE;

    SET is_veteran = (SELECT `is_veteran` FROM employee WHERE id = p_employee_id);
    SELECT COUNT(child.id), salary INTO child_amount, employee_salary
    FROM employee
    LEFT JOIN child ON employee.id = p_employee_id
    AND child.parent_id = employee.id;

    SET privilege_percent = IF(is_veteran, 12, 0) + (child_amount * 2);
    RETURN employee_salary * (100 - privilege_percent) / 100;


END //

CREATE FUNCTION CalculateNDFL(p_employee_id INT)
RETURNS DECIMAL(8, 2)
BEGIN
    DECLARE tax_base DECIMAL(8, 2);
    SET tax_base = CalculateTaxBase(p_employee_id);
    RETURN tax_base * 0.13;
END //

CREATE PROCEDURE CalculateTaxBaseOrNDFL(IN p_employee_id INT, IN operation INT, OUT result DECIMAL(8, 2))
BEGIN
    IF(operation = 1) THEN
        SET result = CalculateTaxBase(p_employee_id);
    ELSEIF(operation = 2) THEN
        SET result = CalculateNDFL(p_employee_id);
    END IF;
END //

CREATE PROCEDURE WriteTaxBaseOrNDFL(IN p_employee_id INT, IN operation INT)
BEGIN
    DECLARE result DECIMAL(8, 2);
    CALL CalculateTaxBaseOrNDFL(p_employee_id, operation, result);

    INSERT INTO accrual(employee_id, type_deduction_id, amount) VALUES
    (p_employee_id, type_deduction, result);
END //

CREATE TRIGGER LogAccruals AFTER INSERT ON accrual
FOR EACH ROW BEGIN
    DECLARE temp_amount DECIMAL(8, 2);
    DECLARE operation_type INT;
    SET temp_amount = IF(NEW.ndfl_amount IS NOT NULL, NEW.ndfl_amount, NEW.ndfl_base);
    SET operation_type = IF(NEW.ndfl_amount IS NOT NULL, 2, 1);

    INSERT INTO proc_logs(employee_id, type_operation_id, amount)
    VALUES (NEW.employee_id, operation_type, temp_amount);

END //