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

-- Заполнение таблицы type_deduction
INSERT INTO type_deduction (name, deduction_amount) VALUES 
('Детский вычет', 2),
('Вычет ветеранам', 12);

-- Заполнение таблицы type_operation
INSERT INTO type_operation (name) VALUES 
('Налоговая база'),
('НДФЛ');

-- Заполнение таблицы employee
INSERT INTO employee (name, salary, is_veteran) VALUES 
('Иванов Иван Иванович', 50000.00, TRUE),
('Петров Петр Петрович', 75000.00, FALSE),
('Сидорова Анна Михайловна', 60000.00, FALSE),
('Кузнецов Дмитрий Сергеевич', 45000.00, TRUE),
('Смирнова Елена Владимировна', 80000.00, FALSE),
('Федоров Алексей Николаевич', 55000.00, FALSE),
('Николаева Ольга Дмитриевна', 65000.00, TRUE),
('Васильев Михаил Андреевич', 70000.00, FALSE),
('Павлова Татьяна Ивановна', 48000.00, FALSE),
('Козлов Артем Викторович', 90000.00, TRUE);

-- Заполнение таблицы child
INSERT INTO child (name, birth_date, parent_id) VALUES 
('Иванова Мария Ивановна', '2015-07-12', 1),
('Иванов Алексей Иванович', '2018-03-25', 1),
('Петрова Дарья Петровна', '2020-11-05', 2),
('Сидоров Максим Антонович', '2005-09-18', 3),
('Сидорова Виктория Антоновна', '2010-12-30', 3),
('Кузнецова Алина Дмитриевна', '2017-02-14', 4),
('Смирнов Игорь Евгеньевич', '2004-06-22', 5),
('Федорова Ксения Алексеевна', '2019-08-15', 6),
('Николаев Артем Олегович', '2016-05-10', 7),
('Николаева Софья Олеговна', '2014-04-03', 7),
('Васильева Анастасия Михайловна', '2013-07-28', 8),
('Павлов Денис Тимурович', '2003-01-20', 9),
('Козлова Полина Артемовна', '2018-09-17', 10),
('Козлов Тимофей Артемович', '2021-10-05', 10);

-- Заполнение таблицы accrual
INSERT INTO accrual (employee_id, type_operation_id, amount) VALUES 
(1, 1, 50000.00),
(1, 2, 6500.00),
(2, 1, 75000.00),
(2, 2, 9750.00),
(3, 1, 60000.00),
(3, 2, 7800.00),
(4, 1, 45000.00),
(4, 2, 5850.00),
(5, 1, 80000.00),
(5, 2, 10400.00),
(6, 1, 55000.00),
(6, 2, 7150.00),
(7, 1, 65000.00),
(7, 2, 8450.00),
(8, 1, 70000.00),
(8, 2, 9100.00),
(9, 1, 48000.00),
(9, 2, 6240.00),
(10, 1, 90000.00),
(10, 2, 11700.00);

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

    INSERT INTO proc_logs(employee_id, type_operation_id, amount)
    VALUES (NEW.employee_id, NEW.type_operation_id, NEW.amount);

END //

