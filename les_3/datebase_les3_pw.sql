/*1. Создать структуру БД Вконтакте по скриптам, приложеным в файле примеров examples.sql.*/
DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;

USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(100)  NOT NULL,
	last_name VARCHAR(100)  NOT NULL,
	email VARCHAR(100)  NOT NULL UNIQUE,
	phone VARCHAR(100)  NOT NULL UNIQUE,
	created_at DATETIME  DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id INT UNSIGNED NOT NULL PRIMARY KEY,
	gender CHAR(1) NOT NULL,
	birthday DATE,
	city VARCHAR(130),
	country VARCHAR(130),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	from_user_id INT UNSIGNED NOT NULL,
	to_user_id INT UNSIGNED NOT NULL,
	body TEXT NOT NULL,
	is_important BOOLEAN,
	is_delivered BOOLEAN,
	create_at DATETIME DEFAULT NOW()
);

DROP TABLE IF EXISTS friendship;
CREATE TABLE friendship (
	user_id INT UNSIGNED NOT NULL,
	friend_id INT UNSIGNED NOT NULL,
	status_id INT UNSIGNED NOT NULL,
	requested_at DATETIME DEFAULT NOW(),
	confirmed_at DATETIME,
	PRIMARY KEY(user_id, friend_id)
);

DROP TABLE IF EXISTS friendship_statuses;
CREATE TABLE friendship_statuses (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(150) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(150) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS communities_users;
CREATE TABLE communities_users (
	communities_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (communities_id, user_id )
);

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id INT UNSIGNED NOT NULL,
	filename VARCHAR(255) NOT NULL,
	size INT NOT NULL,
	metadata JSON,
	media_type_id INT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE
);

 /*2. Используя сервис http://filldb.info или другой по вашему желанию, 
сгенерировать тестовые данные для всех таблиц, учитывая логику связей. 
Для всех таблиц, где это имеет смысл, создать не менее 100 строк. 
Загрузить тестовые данные. Приложить к отчёту полученный дамп с данными.*/

-- mysql vk < fulldb01 - 05 - 2020\ 14-05.sql

/*3. (по желанию) Проанализировать структуру БД vk, которую мы создали на занятии, 
и внести предложения по усовершенствованию (если такие идеи есть). 
Напишите пожалуйста, всё-ли понятно по структуре*/

/*Добавить активность пользователя, атрибуты (статистика активности)
 * атрибуты групы добавить : временые метки, создатель группы .
 По структуре более мение все понятно*/
