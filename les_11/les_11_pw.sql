/*Практическое задание по теме “Оптимизация запросов”
Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах
users, catalogs и products в таблицу logs помещается:
	время и дата создания записи,
	название таблицы,
	идентификатор первичного ключа,
	и содержимое поля name.
*/
-- создать тригер 
-- AFTER INSERT для таблиц: users, catalogs и products
USE shop;
SHOW ENGINES;
SHOW TABLES;
DESC users ;	-- тип полей: id - bigint unsigned, name - varchar(255)
DESC catalogs ;	-- тип полей: id - bigint unsigned, name - varchar(255)
DESC products ;	-- тип полей: id - bigint unsigned, name - varchar(255)

SELECT * FROM users u ;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs(
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	tabl_name VARCHAR(55) NOT NULL,
	id_fields BIGINT UNSIGNED NOT NULL,
	name_fields VARCHAR(55)	NOT NULL
)ENGINE=ARCHIVE;

DROP TRIGGER IF EXISTS check_insert_to_users;
DELIMITER //
CREATE TRIGGER check_insert_to_users AFTER INSERT ON users
FOR EACH ROW 
BEGIN
	INSERT INTO logs(tabl_name, id_fields, name_fields)
	VALUES	('users', NEW.id, NEW.name);
END//
DELIMITER ;
DROP TRIGGER IF EXISTS check_insert_to_catalogs;
DELIMITER //
CREATE TRIGGER check_insert_to_catalogs AFTER INSERT ON catalogs
FOR EACH ROW 
BEGIN
	INSERT INTO logs(tabl_name, id_fields, name_fields)
	VALUES	('catalogs', NEW.id, NEW.name);
END// 
DELIMITER ;
DROP TRIGGER IF EXISTS check_insert_to_products;
DELIMITER //
CREATE TRIGGER check_insert_to_products AFTER INSERT ON products
FOR EACH ROW 
BEGIN
	INSERT INTO logs(tabl_name, id_fields, name_fields)
	VALUES	('products', NEW.id, NEW.name);
END// 
DELIMITER ;

SELECT * FROM users;
INSERT INTO users (name, birthday_at) VALUES
  ('Dmirty', '1980-08-15'),
  ('Vitaliy', '1974-05-22'),
  ('Ales', '1956-02-10'),
  ('Sam', '1982-07-24');

SELECT * FROM products;
INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('AMD Ryzen 3200u', 'Процессор для переносных персональных компьютеров, основанных на платформе AMD.', 5890.00, 1);
  
SELECT * FROM catalogs;
INSERT INTO catalogs 
VALUES (NULL, 'Ноутбуки')
;

SELECT * FROM logs;
 
/*(по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
*/
SELECT CONCAT(CHAR(ROUND(RAND()*25 + 97)),
			CHAR(ROUND(RAND()*25 + 97)),
			CHAR(ROUND(RAND()*25 + 97)),
			CHAR(ROUND(RAND()*25 + 97)),
			CHAR(ROUND(RAND()*25 + 97)));
SELECT (CURDATE() - INTERVAL (ROUND(RAND()*(30*365)) + 10*365) DAY) ;
-- прецедура с циклом

DROP PROCEDURE IF EXISTS insert_million_values_to_users_tbl;
DELIMITER //
CREATE PROCEDURE insert_million_values_to_users_tbl()
BEGIN
	DECLARE itm INT DEFAULT 0;
	WHILE itm <= 1000 DO 
		INSERT users (name, birthday_at)
		VALUES (CONCAT(
					CHAR(ROUND(RAND()*25 + 97)),
					CHAR(ROUND(RAND()*25 + 97)),
					CHAR(ROUND(RAND()*25 + 97)),
					CHAR(ROUND(RAND()*25 + 97)),
					CHAR(ROUND(RAND()*25 + 97))
				),
				(CURDATE() - INTERVAL (ROUND(RAND()*(30*365)) + 10*365) DAY));
  		SET itm = itm + 1;
	END WHILE;
END//
DELIMITER ;

CALL insert_million_values_to_users_tbl(); 
/* добавилось более 100000 затем я перезапустил mysql*/
SELECT COUNT(*) from users;
SELECT * FROM  users u order by created_at desc;

SELECT * FROM logs;

/*Практическое задание по теме “NoSQL”
В базе данных Redis подберите коллекцию для подсчета посещений с
определенных IP-адресов.(не совсем понятно что нужно сделать)
*/

-- добавление в колекцию (содержит только уникальные значения)
SADD IP '127.0.0.1' '127.0.0.1' '192.168.0.103' '127.0.0.2' 

SMEMBERS IP -- выводит список колекции

SCARD IP -- выводит количестко значений в колекции

oleg@oleg-VirtualBox:~$ redis-cli
127.0.0.1:6379> SADD IP '127.0.0.1' '127.0.0.1'
(integer) 1
127.0.0.1:6379> SMEMBERS IP
1) "127.0.0.1"
127.0.0.1:6379> SADD IP '192.168.0.103' '127.0.0.2' 
(integer) 2
127.0.0.1:6379> SMEMBERS IP
1) "192.168.0.103"
2) "127.0.0.2"
3) "127.0.0.1"
127.0.0.1:6379> SCARD IP
(integer) 3
127.0.0.1:6379> 

/*При помощи базы данных Redis решите задачу поиска имени пользователя 
по электронному адресу и наоборот, поиск электронного адреса пользователя 
по его имени.
*/

-- создать две таблицы:
	-- первая: имя email (set name value )
	127.0.0.1:6379> set oleg 'oleg@example.net' 
	OK
	127.0.0.1:6379> set dmitriy 'dmitry@example.net'
	OK
	127.0.0.1:6379> set leonid 'leonid@example.net'
	OK
	
	127.0.0.1:6379> get leonid
	"leonid@example.net"
	127.0.0.1:6379> get dmitriy 
	"dmitry@example.net"
	127.0.0.1:6379> get oleg
	"oleg@example.net"
	
	-- вторая email имя (set email name)
	127.0.0.1:6379> set leonid@example.net leonid 
	OK
	127.0.0.1:6379> set dmitry@example.net dmitriy
	OK
	127.0.0.1:6379> set oleg@example.net 'oleg'
	OK
	127.0.0.1:6379> get dmitry@example.net
	"dmitriy"
	127.0.0.1:6379> get leonid@example.net
	"leonid"
	127.0.0.1:6379> get oleg@example.net
	"oleg"

/*Организуйте хранение категорий и товарных позиций учебной базы данных shop 
в СУБД MongoDB.
*/

db.shop.insertMany([
	{'name': 'Intel Core i3-8100', 'description': 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 'price': '7890.00', 'category': 'Процессоры', 'created_at': new Date(), 'updated_at': new Date()},
	{'name': 'Intel Core i5-7400', 'description': 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 'price': '12700.00', 'category': 'Процессоры', 'created_at': new Date(), 'updated_at': new Date()},
	{'name': 'AMD FX-8320E', 'description': 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 'price': '4780.00', 'category': 'Процессоры', 'created_at': new Date(), 'updated_at': new Date()},
	{'name': 'AMD FX-8320', 'description': 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 'price': '7120.00', 'category': 'Процессоры', 'created_at': new Date(), 'updated_at': new Date()},
	{'name': 'ASUS ROG MAXIMUS X HERO', 'description': 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 'price': '19310.00', 'category': 'Материнские платы', 'created_at': new Date(), 'updated_at': new Date()},
	{'name': 'Gigabyte H310M S2H', 'description': 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 'price': '4790.00', 'category': 'Материнские платы', 'created_at': new Date(), 'updated_at': new Date()},
	{'name': 'MSI B250M GAMING PRO', 'description': 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 'price': '5060.00', 'category': 'Материнские платы', 'created_at': new Date(), 'updated_at': new Date()}
	])

	

