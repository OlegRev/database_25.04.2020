DROP DATABASE IF EXISTS les_7;
CREATE DATABASE les_7;
USE les_7;

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

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

INSERT INTO orders
  	SELECT 
    	id, 
    	FLOOR(1 + (RAND() * (SELECT COUNT(*) FROM users))), 
    	CURRENT_TIMESTAMP ,
		CURRENT_TIMESTAMP 
	FROM users;
 
SELECT * FROM orders ;
SELECT * FROM products ;
 
INSERT INTO orders_products
	SELECT 
    	id, 
    	FLOOR(1 + (RAND() * (SELECT COUNT(*) FROM orders))), 
    	FLOOR(1 + (RAND() * (SELECT COUNT(*) FROM products))),
    	FLOOR(1 + (RAND() * 27)),
    	CURRENT_TIMESTAMP ,
    	CURRENT_TIMESTAMP 
	FROM orders;

SELECT * FROM orders_products ;
/*1.Составьте список пользователей users,
которые осуществили хотя бы один заказ orders в интернет магазине.
*/

SELECT id,
	name 
FROM users
	WHERE users.id 
		IN (
		SELECT user_id FROM orders
	);

SELECT users.id, users.name 
FROM users, orders 
	WHERE users.id = orders.user_id
	GROUP BY users.id;

SELECT users.id, users.name 
FROM users JOIN orders 
	ON users.id = orders.user_id
	GROUP BY users.id;

/*2.Выведите список товаров products и разделов catalogs,
который соответствует товару.
*/
DESC catalogs ;
SELECT p.name, 
	(SELECT name FROM catalogs c 
		WHERE c.id = p.catalog_id
	) AS catalogs
FROM products p ;

SELECT p.name ,
	c.name AS catalogs
FROM products p ,catalogs c
	WHERE c.id = p.catalog_id ;

SELECT p.name ,
	c.name AS catalogs
FROM products p JOIN catalogs c
	ON c.id = p.catalog_id ;

/*3.(по желанию) Пусть имеется таблица рейсов
flights (id, from, to) и таблица городов cities (label, name).
Поля from, to и label содержат английские названия городов, 
поле name — русское.
Выведите список рейсов flights с русскими названиями городов.
*/

DROP TABLE IF EXISTS les_7.flights;
CREATE TABLE les_7.flights(
	id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
	from_city VARCHAR(50) NOT NULL,
	to_city VARCHAR(50) NOT NULL
);


INSERT INTO les_7.flights (from_city, to_city) VALUES
	('moscow', 'omsk'),
	('novgorod', 'kazan'),
	('irkutsk', 'moscow'),
	('omsk', 'irkutsk'),
	('moscow', 'kazan');


CREATE TABLE les_7.cities(
	label VARCHAR(50) NOT NULL,
	name VARCHAR(50) NOT NULL,
	PRIMARY KEY(label, name)
);

INSERT INTO  les_7.cities(label, name) VALUES(
	'moscow', 'Москва'),
	('irkutsk', 'Иркутск'),
	('novgorod', 'Новгород'),
	('kazan', 'Казань'),
	('omsk', 'Омск');

SELECT * FROM les_7.flights;
SELECT id,
	(SELECT c.name FROM cities c 
		WHERE f.from_city = c.label) AS 'из города', 
	(SELECT c.name FROM cities c 
		WHERE f.to_city = c.label) AS 'в город' 
FROM flights f ;



SELECT f.id,
	c.name AS 'из города',
	c2.name AS 'в город'
FROM flights f, cities c, cities c2 
	WHERE f.from_city = c.label AND f.to_city = c2.label ;

SELECT f.id,
	c.name
FROM flights f JOIN cities c
	ON f.from_city = c.label OR f.to_city =c.label ;

SELECT f.id,
	c.name AS 'из города',
	c2.name AS 'в город'
FROM flights f 
	JOIN cities c
	JOIN cities c2 
	ON f.from_city = c.label 
		AND f.to_city = c2.label;


	

