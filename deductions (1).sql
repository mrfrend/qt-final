-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Апр 24 2025 г., 21:52
-- Версия сервера: 8.0.30
-- Версия PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `deductions`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`root`@`%` PROCEDURE `CalculateTaxBaseOrNDFL` (IN `p_employee_id` INT, IN `operation` INT, IN `consider_veteran` BOOLEAN, IN `consider_children` BOOLEAN, OUT `result` DECIMAL(8,2))   BEGIN
    IF(operation = 1) THEN
        SET result = CalculateTaxBase(p_employee_id, consider_veteran, consider_children);
    ELSEIF(operation = 2) THEN
        SET result = CalculateNDFL(p_employee_id, consider_veteran, consider_children);
    END IF;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `WriteTaxBaseOrNDFL` (IN `p_employee_id` INT, IN `operation` INT, IN `consider_veteran` BOOLEAN, IN `consider_children` BOOLEAN)   BEGIN
    DECLARE result DECIMAL(8, 2);
    CALL CalculateTaxBaseOrNDFL(p_employee_id, operation, consider_veteran, consider_children, result);

    INSERT INTO accrual(employee_id, type_operation_id, amount) VALUES
    (p_employee_id, operation, result);
END$$

--
-- Функции
--
CREATE DEFINER=`root`@`%` FUNCTION `CalculateNDFL` (`p_employee_id` INT, `consider_veteran` BOOLEAN, `consider_children` BOOLEAN) RETURNS DECIMAL(8,2)  BEGIN
    DECLARE tax_base DECIMAL(8, 2);
    SET tax_base = CalculateTaxBase(p_employee_id, consider_veteran, consider_children);
    RETURN tax_base * 0.13;
END$$

CREATE DEFINER=`root`@`%` FUNCTION `CalculateTaxBase` (`p_employee_id` INT, `consider_veteran` BOOLEAN, `consider_children` BOOLEAN) RETURNS DECIMAL(8,2) READS SQL DATA BEGIN
    DECLARE base_salary DECIMAL(8,2);
    DECLARE veteran_discount INT DEFAULT 0;
    DECLARE children_discount INT DEFAULT 0;
    DECLARE total_discount INT;
    DECLARE tax_base DECIMAL(8,2);
    
    -- Получаем базовую зарплату сотрудника
    SELECT salary INTO base_salary 
    FROM employee 
    WHERE id = p_employee_id;
    
    -- Проверяем ветеранский статус (если требуется)
    IF consider_veteran THEN
        SELECT IF(`is_veteran` = 1, 12, 0) INTO veteran_discount
        FROM employee
        WHERE id = p_employee_id;
    END IF;
    
    -- Считаем детские льготы (если требуется)
    IF consider_children THEN
        SELECT COUNT(*) * 2 INTO children_discount
        FROM child
        WHERE parent_id = p_employee_id
        AND TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) < 18;
    END IF;
    
    -- Суммируем все льготы
    SET total_discount = veteran_discount + children_discount;
    
    -- Рассчитываем налоговую базу
    SET tax_base = base_salary * (100 - total_discount) / 100;
    
    RETURN tax_base;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `accrual`
--

CREATE TABLE `accrual` (
  `id` int NOT NULL,
  `employee_id` int NOT NULL,
  `date_accrual` date DEFAULT (CURRENT_DATE),
  `type_operation_id` int DEFAULT NULL,
  `amount` decimal(8,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `accrual`
--

INSERT INTO `accrual` (`id`, `employee_id`, `date_accrual`, `type_operation_id`, `amount`) VALUES
(1, 1, '2025-04-02', 1, '50000.00'),
(2, 1, '2025-04-02', 2, '6500.00'),
(3, 2, '2025-04-02', 1, '75000.00'),
(4, 2, '2025-04-02', 2, '9750.00'),
(5, 3, '2025-04-02', 1, '60000.00'),
(6, 3, '2025-04-02', 2, '7800.00'),
(7, 4, '2025-04-02', 1, '45000.00'),
(8, 4, '2025-04-02', 2, '5850.00'),
(9, 5, '2025-04-02', 1, '80000.00'),
(10, 5, '2025-04-02', 2, '10400.00'),
(11, 6, '2025-04-02', 1, '55000.00'),
(12, 6, '2025-04-02', 2, '7150.00'),
(13, 7, '2025-04-02', 1, '65000.00'),
(14, 7, '2025-04-02', 2, '8450.00'),
(15, 8, '2025-04-02', 1, '70000.00'),
(16, 8, '2025-04-02', 2, '9100.00'),
(17, 9, '2025-04-02', 1, '48000.00'),
(18, 9, '2025-04-02', 2, '6240.00'),
(19, 10, '2025-04-02', 1, '90000.00'),
(20, 10, '2025-04-02', 2, '11700.00'),
(21, 1, '2025-04-09', 2, '5460.00'),
(22, 2, '2025-04-09', 2, '9750.00'),
(23, 10, '2025-04-23', 2, '9828.00'),
(24, 1, '2025-04-23', 2, '5720.00'),
(25, 6, '2025-04-24', 1, '53900.00'),
(26, 6, '2025-04-24', 2, '7007.00');

--
-- Триггеры `accrual`
--
DELIMITER $$
CREATE TRIGGER `LogAccruals` AFTER INSERT ON `accrual` FOR EACH ROW BEGIN
    DECLARE temp_amount DECIMAL(8, 2);
    DECLARE operation_type INT;

    INSERT INTO proc_logs(employee_id, type_operation_id, amount)
    VALUES (NEW.employee_id, NEW.type_operation_id, NEW.amount);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `child`
--

CREATE TABLE `child` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `birth_date` date NOT NULL,
  `parent_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `child`
--

INSERT INTO `child` (`id`, `name`, `birth_date`, `parent_id`) VALUES
(1, 'Иванова Мария Ивановна', '2015-07-12', 1),
(2, 'Иванов Алексей Иванович', '2018-03-25', 1),
(3, 'Петрова Дарья Петровна', '2020-11-05', 2),
(4, 'Сидоров Максим Антонович', '2005-09-18', 3),
(5, 'Сидорова Виктория Антоновна', '2010-12-30', 3),
(6, 'Кузнецова Алина Дмитриевна', '2017-02-14', 4),
(7, 'Смирнов Игорь Евгеньевич', '2004-06-22', 5),
(8, 'Федорова Ксения Алексеевна', '2019-08-15', 6),
(9, 'Николаев Артем Олегович', '2016-05-10', 7),
(10, 'Николаева Софья Олеговна', '2014-04-03', 7),
(11, 'Васильева Анастасия Михайловна', '2013-07-28', 8),
(12, 'Павлов Денис Тимурович', '2003-01-20', 9),
(13, 'Козлова Полина Артемовна', '2018-09-17', 10),
(14, 'Козлов Тимофей Артемович', '2021-10-05', 10);

-- --------------------------------------------------------

--
-- Структура таблицы `employee`
--

CREATE TABLE `employee` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `salary` decimal(8,2) DEFAULT NULL,
  `is_veteran` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `employee`
--

INSERT INTO `employee` (`id`, `name`, `salary`, `is_veteran`) VALUES
(1, 'Иванов Иван Иванович', '50000.00', 1),
(2, 'Петров Петр Петрович', '75000.00', 0),
(3, 'Сидорова Анна Михайловна', '60000.00', 0),
(4, 'Кузнецов Дмитрий Сергеевич', '45000.00', 1),
(5, 'Смирнова Елена Владимировна', '80000.00', 0),
(6, 'Федоров Алексей Николаевич', '55000.00', 0),
(7, 'Николаева Ольга Дмитриевна', '65000.00', 1),
(8, 'Васильев Михаил Андреевич', '70000.00', 0),
(9, 'Павлова Татьяна Ивановна', '48000.00', 0),
(10, 'Козлов Артем Викторович', '90000.00', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `proc_logs`
--

CREATE TABLE `proc_logs` (
  `id` int NOT NULL,
  `employee_id` int NOT NULL,
  `type_operation_id` int NOT NULL,
  `amount` decimal(8,2) NOT NULL,
  `operation_datetime` datetime DEFAULT (CURRENT_TIMESTAMP)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `proc_logs`
--

INSERT INTO `proc_logs` (`id`, `employee_id`, `type_operation_id`, `amount`, `operation_datetime`) VALUES
(1, 1, 1, '50000.00', '2025-04-02 21:23:30'),
(2, 1, 2, '6500.00', '2025-04-02 21:23:30'),
(3, 2, 1, '75000.00', '2025-04-02 21:23:30'),
(4, 2, 2, '9750.00', '2025-04-02 21:23:30'),
(5, 3, 1, '60000.00', '2025-04-02 21:23:30'),
(6, 3, 2, '7800.00', '2025-04-02 21:23:30'),
(7, 4, 1, '45000.00', '2025-04-02 21:23:30'),
(8, 4, 2, '5850.00', '2025-04-02 21:23:30'),
(9, 5, 1, '80000.00', '2025-04-02 21:23:30'),
(10, 5, 2, '10400.00', '2025-04-02 21:23:30'),
(11, 6, 1, '55000.00', '2025-04-02 21:23:30'),
(12, 6, 2, '7150.00', '2025-04-02 21:23:30'),
(13, 7, 1, '65000.00', '2025-04-02 21:23:30'),
(14, 7, 2, '8450.00', '2025-04-02 21:23:30'),
(15, 8, 1, '70000.00', '2025-04-02 21:23:30'),
(16, 8, 2, '9100.00', '2025-04-02 21:23:30'),
(17, 9, 1, '48000.00', '2025-04-02 21:23:30'),
(18, 9, 2, '6240.00', '2025-04-02 21:23:30'),
(19, 10, 1, '90000.00', '2025-04-02 21:23:30'),
(20, 10, 2, '11700.00', '2025-04-02 21:23:30'),
(21, 1, 2, '5460.00', '2025-04-09 23:34:49'),
(22, 2, 2, '9750.00', '2025-04-09 23:46:40'),
(23, 10, 2, '9828.00', '2025-04-23 18:55:56'),
(24, 1, 2, '5720.00', '2025-04-23 19:38:40'),
(25, 6, 1, '53900.00', '2025-04-24 21:50:06'),
(26, 6, 2, '7007.00', '2025-04-24 21:50:08');

-- --------------------------------------------------------

--
-- Структура таблицы `type_deduction`
--

CREATE TABLE `type_deduction` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `deduction_amount` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `type_deduction`
--

INSERT INTO `type_deduction` (`id`, `name`, `deduction_amount`) VALUES
(1, 'Детский вычет', 2),
(2, 'Вычет ветеранам', 12),
(3, 'Тестовое значение', 10);

-- --------------------------------------------------------

--
-- Структура таблицы `type_operation`
--

CREATE TABLE `type_operation` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `type_operation`
--

INSERT INTO `type_operation` (`id`, `name`) VALUES
(1, 'Налоговая база'),
(2, 'НДФЛ'),
(3, 'Тест');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `accrual`
--
ALTER TABLE `accrual`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `type_operation_id` (`type_operation_id`);

--
-- Индексы таблицы `child`
--
ALTER TABLE `child`
  ADD PRIMARY KEY (`id`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Индексы таблицы `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `proc_logs`
--
ALTER TABLE `proc_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `type_operation_id` (`type_operation_id`);

--
-- Индексы таблицы `type_deduction`
--
ALTER TABLE `type_deduction`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `type_operation`
--
ALTER TABLE `type_operation`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `accrual`
--
ALTER TABLE `accrual`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT для таблицы `child`
--
ALTER TABLE `child`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT для таблицы `employee`
--
ALTER TABLE `employee`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT для таблицы `proc_logs`
--
ALTER TABLE `proc_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT для таблицы `type_deduction`
--
ALTER TABLE `type_deduction`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `type_operation`
--
ALTER TABLE `type_operation`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `accrual`
--
ALTER TABLE `accrual`
  ADD CONSTRAINT `accrual_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`id`),
  ADD CONSTRAINT `accrual_ibfk_2` FOREIGN KEY (`type_operation_id`) REFERENCES `type_operation` (`id`);

--
-- Ограничения внешнего ключа таблицы `child`
--
ALTER TABLE `child`
  ADD CONSTRAINT `child_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `employee` (`id`);

--
-- Ограничения внешнего ключа таблицы `proc_logs`
--
ALTER TABLE `proc_logs`
  ADD CONSTRAINT `proc_logs_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`id`),
  ADD CONSTRAINT `proc_logs_ibfk_2` FOREIGN KEY (`type_operation_id`) REFERENCES `type_operation` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
