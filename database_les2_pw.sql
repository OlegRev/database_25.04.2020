/* 2.Создайте базу данных example, разместите в ней таблицу users,
 состоящую из двух столбцов, числового id и строкового name.*/

DROP DATABASE IF EXISTS example; 
CREATE DATABASE example;

USE example;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	name VARCHAR(255) 
);

/* 3.Создайте дамп базы данных example из предыдущего задания,
 * разверните содержимое дампа в новую базу данных sample.*/

\! mysqldump example > example_db.sql

DROP DATABASE IF EXISTS sample;
CREATE DATABASE sample;

\! mysql sample < example_db.sql

/*4.(по желанию) Ознакомьтесь более подробно с документацией
 утилиты mysqldump. Создайте дамп единственной таблицы help_keyword
 базы данных mysql. Причем добейтесь того, чтобы дамп содержал
 только первые 100 строк таблицы.*/

\! mysqldump --WHERE='TRUE LIMIT 100' mysql help_keyword > mysqsl_help_k_100.sql
