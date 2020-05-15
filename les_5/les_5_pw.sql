-- Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение”
/*Пусть в таблице users поля created_at и updated_at оказались незаполненными.
Заполните их текущими датой и временем.
*/
DROP DATABASE IF EXISTS LES_5;
CREATE DATABASE LES_5;

USE LES_5;


DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME ,
  updated_at DATETIME 
) COMMENT = 'Покупатели';

SELECT * FROM LES_5.users; -- ПУСТЫЕ ПОЛЯ

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
 
SELECT * FROM LES_5.users; -- created_at updated_at == NULL

UPDATE  LES_5.users SET created_at = NOW(),
						updated_at = NOW();

DESCRIBE LES_5.users;
					
ALTER TABLE LES_5.users CHANGE COLUMN created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP ;
ALTER TABLE LES_5.users CHANGE COLUMN updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESC LES_5.users;



/*Таблица users была неудачно спроектирована. Записи created_at и updated_at 
были заданы типом VARCHAR и в них долгое время помещались значения 
в формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME,
сохранив введеные ранее значения.
*/

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(100) ,
  updated_at VARCHAR(100)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Геннадий', '1990-10-05', "26.10.2017 8:10", "20.10.2019 8:10"),
  ('Наталья', '1984-11-12', "20.10.2016 00:10", "20.10.2019 8:10"),
  ('Александр', '1985-05-20', "10.09.2016 7:10", "20.10.2019 8:10"),
  ('Сергей', '1988-02-14', "30.12.2017 12:10", "20.10.2019 8:10"),
  ('Иван', '1998-01-12', "20.07.2017 10:00", "20.10.2019 8:10"),
  ('Мария', '1992-08-29', "02.06.2019 9:10", "25.07.2019 8:10");
 

SELECT name, STR_TO_DATE(created_at, '%d.%m.%Y %H:%i') FROM LES_5.users ;
SELECT name, STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i') FROM LES_5.users ;

ALTER TABLE LES_5.users ADD DT_created_at DATETIME;
UPDATE LES_5.users SET DT_created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i');

ALTER TABLE LES_5.users ADD DT_updated_at DATETIME;
UPDATE LES_5.users SET DT_updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');

SELECT * FROM users;

ALTER TABLE LES_5.users DROP created_at ;
ALTER TABLE LES_5.users DROP updated_at ;
ALTER TABLE LES_5.users RENAME COLUMN DT_created_at TO created_at;
ALTER TABLE LES_5.users RENAME COLUMN DT_updated_at TO updated_at;

/*В таблице складских запасов storehouses_products в поле value могут 
встречаться самые разные цифры: 0, если товар закончился и выше нуля, 
если на складе имеются запасы. Необходимо отсортировать записи таким образом,
чтобы они выводились в порядке увеличения значения value. Однако, нулевые 
запасы должны выводиться в конце, после всех записей.
*/
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';


INSERT INTO storehouses_products (value) VALUES
  (82),(45),(10),(0),(9),(123),(0),(2500),(30),(500),(1) ;
 
SELECT * FROM storehouses_products ;
SELECT * FROM storehouses_products  ORDER BY IF(value=0, 1, 0), value ;

/*(по желанию) Из таблицы users необходимо извлечь пользователей, родившихся 
в августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')
*/


DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
 
SELECT * FROM users WHERE MONTHNAME(birthday_at) IN ('may', 'august'); 

-- если значение даты задана как VARCHAR
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at VARCHAR(255) COMMENT 'Дата рождения'
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990 october 05'),
  ('Наталья', '1984 november 12'),
  ('Александр', '1985 may 20'),
  ('Сергей', '1988 february 14'),
  ('Иван', '1998 january 12'),
  ('Мария', '1992 august 29');
 
SELECT * FROM users;

SELECT * FROM users WHERE birthday_at RLIKE 'august'|'may';

/*(по желанию) Из таблицы catalogs извлекаюся записи при помощи запрос. 
SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке,
заданном в списке IN.
*/

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

SELECT * FROM catalogs WHERE id IN (5, 1, 2);
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id,5,1,2);
 
-- Практическое задание теме “Агрегация данных”
/*Подсчитайте средний возраст пользователей в таблице users
*/

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');
 
SELECT TIMESTAMPDIFF(YEAR,birthday_at,NOW()) FROM users;
SELECT FLOOR(AVG(TIMESTAMPDIFF(YEAR,birthday_at,NOW()))) AS users_average_age FROM users;

/*Подсчитайте количество дней рождения, которые приходятся на каждый из дней 
недели. Следует учесть, что необходимы дни недели текущего года, 
а не года рождения.
*/
SELECT DAYNAME('1992-03-10');
SELECT name, birthday_at ,WEEKDAY(birthday_at), DAYNAME(birthday_at) FROM users ;
SELECT name,birthday_at ,
		DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) AS dayname_now ,
		WEEKDAY(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) as weekday_now
		FROM users ; -- дни недели birthday_at в YEAR(NOW())

SELECT  COUNT(*),
		DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) AS dayname_now 
		FROM users  GROUP BY dayname_now ;

SELECT  COUNT(*),
		WEEKDAY(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) as weekday_now , 
		DAYNAME(CONCAT(YEAR(NOW()),'-',MONTH(birthday_at),'-',DAY(birthday_at))) AS dayname_now 
		FROM users  
		GROUP BY weekday_now,dayname_now 
		ORDER BY weekday_now DESC ;

/*(по желанию) Подсчитайте произведение чисел в столбце таблицы
 */
	
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';


INSERT INTO storehouses_products (value) VALUES
  (82),(45),(10),(0),(9),(123),(0),(2500),(30),(500),(1) ;
 
INSERT INTO storehouses_products (value) VALUES
  (1),(2),(3),(4),(5) ; -- произведение чиесл = 120
 
SELECT value FROM storehouses_products;
SELECT EXP(SUM(LN(value))) AS product_of_numbers_in_value FROM  storehouses_products;  
-- логарифм произведения равен сумме логарифмов(експонента в степени натурального логарифма "числа" = "числу") 
-- SUM(LN(value))  получаем натуральный логарифм по произведению value
-- EXP(SUM(LN(value))) експонента в степени натурального логарифма("числа") = "числу"


