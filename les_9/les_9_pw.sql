USE shop;

/*Практическое задание по теме “Транзакции, переменные, представления”
В базе данных shop и sample присутствуют одни и те же таблицы, 
учебной базы данных. Переместите запись id = 1 из таблицы shop.users 
в таблицу sample.users. Используйте транзакции.
*/

SELECT * FROM shop.users;
TRUNCATE TABLE sample.users; 
SELECT * FROM sample.users;

START TRANSACTION;
	INSERT INTO sample.users SELECT *FROM shop.users WHERE id = 1;
	DELETE FROM shop.users WHERE id = 1;
COMMIT;

SELECT * FROM sample.users;
SELECT * FROM shop.users;

/*Создайте представление, которое выводит название name товарной позиции из
таблицы products и соответствующее название каталога name из таблицы catalogs.
*/

CREATE VIEW prod_cat AS
	SELECT p.name, c.name AS catalog_name
FROM products p
	JOIN catalogs c
	ON p.catalog_id= c.id; 

SELECT * FROM prod_cat;
DROP VIEW IF EXISTS prod_cat;

/*(по желанию) Пусть имеется таблица с календарным полем created_at. 
В ней размещены разряженые календарные записи за август 2018 года 
'2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, 
который выводит полный список дат за август, выставляя в соседнем поле
значение 1, если дата присутствует в исходном таблице и 0,
если она отсутствует.
*/

DROP TABLE IF EXISTS day_of_august;
CREATE TABLE day_of_august(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	created_at DATE );

INSERT INTO day_of_august (created_at) VALUES
	('2018-08-01'),
	('2018-08-04'),
	('2018-08-16'),
	('2018-08-17'
);

DROP TEMPORARY TABLE IF EXISTS days;
CREATE TEMPORARY TABLE days (
	day INT
);

INSERT INTO days VALUES
(0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20),
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30);
 
SELECT
	DATE(DATE('2018-08-1') + INTERVAL d.day DAY) AS day,
	NOT ISNULL(doa.created_at) AS exist
FROM
	days AS d
LEFT JOIN
	day_of_august AS doa
ON
	DATE(DATE('2018-08-1') + INTERVAL d.day DAY) IN (doa.created_at)
ORDER BY
	day;

/*(по желанию) Пусть имеется любая таблица с календарным полем created_at.
Создайте запрос, который удаляет устаревшие записи из таблицы, 
оставляя только 5 самых свежих записей.
*/

INSERT INTO day_of_august (created_at) VALUES
	('2018-08-14'),
	('2018-08-24'),
	('2018-08-25'),
	('2018-08-26'),
	('2018-08-29'
);
-- вложеный запрос
DELETE doa 
FROM day_of_august doa
	JOIN (SELECT created_at 
		FROM day_of_august doa 
			ORDER BY created_at DESC 
			LIMIT 5, 1) AS del_date
	ON doa.created_at <= del_date.created_at;

-- представление 
CREATE VIEW del_date AS
	SELECT created_at 
	FROM day_of_august doa 
		ORDER BY created_at DESC 
		LIMIT 5, 1;
	

DELETE doa 
FROM day_of_august doa
	JOIN del_date
	ON doa.created_at <= del_date.created_at;

-- переменные
SET @count_lim = (SELECT created_at 
				 FROM day_of_august doa 
					ORDER BY created_at DESC 
					LIMIT 5, 1);

DELETE doa 
FROM day_of_august doa
	JOIN del_date
	ON doa.created_at <= @count_lim;

SELECT * FROM day_of_august doa ;

DROP VIEW del_date;



/*Практическое задание по теме “Администрирование MySQL” 
(эта тема изучается по вашему желанию)
Создайте двух пользователей которые имеют доступ к базе данных shop. 
Первому пользователю shop_read должны быть доступны только запросы на чтение
данных, второму пользователю shop — любые операции в пределах базы данных shop.
*/

CREATE USER 'shop_read'@'localhost';
GRANT SELECT, SHOW VIEW ON shop.* TO 'shop_read'@'localhost' IDENTIFIED BY '';

SHOW DATABASES;
USE shop;
SHOW TABLES;
SELECT * FROM catalogs;
INSERT INTO catalogs (name) VALUES ('Оперативныя память');

CREATE USER 'shop'@'localhost';
GRANT ALL ON shop.* TO 'shop'@'localhost' IDENTIFIED BY '';

/*(по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, 
password, содержащие первичный ключ, имя пользователя и его пароль. 
Создайте представление username таблицы accounts, предоставляющий доступ
к столбца id и name. Создайте пользователя user_read, который б
ы не имел доступа к таблице accounts, однако, мог бы извлекать записи 
из представления username.
*/

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	password VARCHAR(255)
);	

INSERT INTO accounts (name, password) VALUES
	('Oleg', 'hgc1h2c3h123'),
	('Leonid', '13hr7fbi89234'),
	('Dmitry', '0nufp98h013');

CREATE VIEW username AS SELECT id, name FROM accounts;

SELECT * FROM username;

CREATE USER 'user_read'@'localhost';
GRANT SELECT (id, name) ON shop.username TO 'user_read'@'localhost';

/*Практическое задание по теме “Хранимые процедуры и функции, триггеры"
Создайте хранимую функцию hello(), которая будет возвращать приветствие,
в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна 
возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать 
фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 
— "Доброй ночи".
 */

DROP FUNCTION IF EXISTS hello;

DELIMITER //

CREATE FUNCTION hello()
RETURNS TINYTEXT NO SQL
BEGIN
	DECLARE hour_ INT;
	SET hour_ = HOUR(NOW());
	CASE
		WHEN hour_ BETWEEN 0 AND 5 THEN 
			RETURN "Доброй ночи";
		WHEN hour_ BETWEEN 6 AND 11 THEN 
			RETURN "Доброе утро";
		WHEN hour_ BETWEEN 12 AND 17 THEN 
			RETURN "Добрый день";
		WHEN hour_ BETWEEN 18 AND 23 THEN 
			RETURN "Добрый вечер";
	END CASE;
END//

DELIMITER ;
SELECT NOW(), hello ();

/*В таблице products есть два текстовых поля: name с названием товара и 
description с его описанием. Допустимо присутствие обоих полей или одно из них.
Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля 
были заполнены. При попытке присвоить полям NULL-значение необходимо 
отменить операцию.
*/

DELIMITER //

DROP TRIGGER IF EXISTS check_product_null_insert//
CREATE TRIGGER check_product_null_insert BEFORE INSERT ON products
FOR EACH ROW 
BEGIN 	
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Both name and description are NULL';
	END IF;
END//

DROP TRIGGER IF EXISTS check_product_null_update//
CREATE TRIGGER check_product_null_update BEFORE UPDATE ON products
FOR EACH ROW 
BEGIN 	
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Both name and description are NULL';
	END IF;
END//

DELIMITER ;

/*(по желанию) Напишите хранимую функцию для вычисления произвольного числа 
Фибоначчи. Числами Фибоначчи называется последовательность в которой число
равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен 
возвращать число 55.
*/

DELIMITER //

CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE fs DOUBLE;
	SET fs = SQRT(5);
	RETURN (POW((1 + fs) / 2.0, num) + POW((1 - fs) / 2.0, num)) / fs;
END//

SELECT FIBONACCI(10)//

DELIMITER ;