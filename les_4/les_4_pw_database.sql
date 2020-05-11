-- Практическое задание по теме "CRUD - операции (les_4)"
USE vk;
SHOW TABLES;
-- 1 Повторить все действия по доработке БД vk.

-- Коректировка значений таблиц
SELECT * FROM vk.users;
SELECT * FROM vk.users WHERE created_at > updated_at ; 


-- Добавляем таблицу со статусами user_statuses (Статус пользователя (active, blocked, deleted)). И столбец status_id в таблицу users.
CREATE TABLE user_statuses (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(150) NOT NULL UNIQUE
);

DESC vk.user_statuses ;

INSERT vk.user_statuses (id, name)
	VALUES 
	(1, 'active'),
	(2, 'blocked'),
	(3, 'delete');
SELECT * FROM vk.user_statuses ;

ALTER TABLE vk.users ADD status_id INT UNSIGNED NOT NULL DEFAULT 1 AFTER phone;



SELECT * FROM vk.profiles;
DESC vk.profiles;
-- удалить дублирование метки создания профиля created_at:
DESC vk.profiles;
ALTER TABLE vk.profiles DROP COLUMN created_at;

-- добавляем фотографии пользователя - photo_id

ALTER TABLE vk.profiles ADD photo_id INT UNSIGNED AFTER user_id;

-- Профиль пользователя открытый или закрытый. Добавляем столбец is_private в таблицу profiles
ALTER TABLE vk.profiles ADD is_private BOOLEAN DEFAULT FALSE AFTER country;

-- Корректировка тестовых данных:
-- Таблица vk.users
UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE created_at > updated_at;

SELECT * FROM vk.users WHERE created_at > updated_at ; 
DESC vk.users ;

-- Таблица vk.profiles
-- день рождения создание профиля править данные с заменой !!

SELECT * FROM vk.profiles WHERE birthday > updated_at ;

SELECT profiles.birthday, users.created_at  FROM vk.profiles JOIN vk.users 
	WHERE vk.profiles.birthday > vk.users.created_at AND vk.profiles.user_id = vk.users.id ;	-- получение строк где значение дня рождения больше значения регистрации пользователя (108 строк)

DESC vk.profiles;
DESC vk.users ;

UPDATE vk.profiles, vk.users 
	SET vk.profiles.birthday = vk.profiles.birthday  - INTERVAL 10 YEAR 
	WHERE vk.profiles.birthday > vk.users.created_at AND vk.profiles.user_id = vk.users.id ; -- обновление данных значения дня рождения

SELECT * FROM  vk.profiles ;
-- добавления данных  photo_id
UPDATE vk.profiles SET photo_id = FLOOR(1 + RAND() * 100 ); 
UPDATE profiles SET photo_id = FLOOR(1 + RAND() * 100);

-- В случае не коректного дампа поля gender
	-- Поправим столбец пола
	-- Создаём временную таблицу значений для пола
	CREATE TEMPORARY TABLE genders (name CHAR(1));	-- Заполняем значениями
	INSERT INTO genders VALUES ('m'), ('w');
	-- Проверяем
	SELECT * FROM genders;
	-- Обновляем пол
	UPDATE profiles 
  		SET gender = (SELECT name FROM genders ORDER BY RAND() LIMIT 1);

-- Проставляем приватность
UPDATE vk.profiles SET is_private = TRUE WHERE user_id > FLOOR(1 +RAND() * 1000); 
SELECT * FROM vk.profiles ;

  	
  	
-- Таблица vk.messages
SELECT * FROM vk.messages;
SELECT * FROM vk.messages WHERE from_user_id = to_user_id ;
-- 3 пункта совпадения обновить значения from_user_id и to_user_id
UPDATE vk.messages SET 
  from_user_id = FLOOR(1 + RAND() * 1000),
  to_user_id = FLOOR(1 + RAND() * 1000)
  WHERE from_user_id = to_user_id;

DESC vk.messages ;
-- опечатка в имени столбца created_at (create_at) во время создания таблицы
ALTER TABLE vk.messages CHANGE COLUMN create_at created_at DATETIME DEFAULT NOW();


-- Таблица vk.media
SELECT * FROM vk.media;
DESC vk.media ;

 -- Обновляем данные для ссылки на тип и владельца

UPDATE vk.media SET user_id = FLOOR(1 + RAND() * 1000);

-- доработка пути к файлу
UPDATE vk.media SET filename = 'https://dropbox/vk/' + filename + ;

-- для прибавления расширения создаем таблицу
DROP TEMPORARY TABLE IF EXISTS extensions ;
CREATE TEMPORARY TABLE extensions (name VARCHAR(10));
INSERT INTO extensions VALUES ('.jpeg'), ('.mpeg'), ('.avi'), ('.png');
SELECT * FROM extensions;

(SELECT name FROM extensions ORDER BY RAND() LIMIT 1); 

UPDATE media SET filename = CONCAT( 
					'https://dropbox/vk/' ,
					filename ,
					(SELECT name FROM extensions ORDER BY RAND() LIMIT 1)); 
SELECT * FROM vk.media ;

-- обновляем рамер меньше 10000
SELECT * FROM vk.media WHERE `size` < 10000;
UPDATE vk.media SET size = FLOOR(10000 + (RAND() * 1000000)) WHERE size < 10000;
SELECT * FROM vk.media;

-- Обновляем метаданные
UPDATE vk.media SET metadata = CONCAT(
	'{"owner":"', 
	(SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
	'"}'
	);  

-- Возвращаем столбцу метеданных правильный тип
ALTER TABLE vk.media MODIFY COLUMN metadata JSON;
DESC vk.media ;

SELECT * FROM vk.media WHERE created_at > updated_at ;

-- Таблица vk.media_types;
-- Анализируем типы медиаконтента
SELECT * FROM vk.media_types;
DESC vk.media_types ;

-- Удаляем все типы
DELETE FROM vk.media_types;

-- Добавляем нужные типы
INSERT INTO vk.media_types (name) VALUES
  ('photo'),
  ('video'),
  ('audio');
 
 TRUNCATE vk.media_types; 
 

UPDATE vk.media SET media_type_id = FLOOR(1 + RAND() * 3);

-- Таблица vk.friendship
SELECT * FROM vk.friendship;
SELECT * FROM vk.friendship WHERE friend_id = user_id ; -- 0 пунктов обновление не требуется
DESC vk.friendship ;

SELECT * FROM vk.friendship WHERE requested_at > confirmed_at ;
ALTER TABLE vk.friendship CHANGE COLUMN requested_at requested_at DATETIME ; -- изменение DESC requested_at что бы данные не обновились по функции NOW()
SELECT NOW() - INTERVAL 10 YEAR;

UPDATE vk.friendship SET requested_at = requested_at - INTERVAL 10 YEAR 
							WHERE requested_at > confirmd_at ;	-- обновление данных requested_at > confirmed_at (по шаблону: requested_at - 10 лет)

ALTER TABLE vk.friendship CHANGE COLUMN requested_at requested_at DATETIME DEFAULT NOW(); -- возвращение requested_at изначального DESC
-- Таблица vk.friendship_statuses
SELECT * FROM vk.friendship_statuses;
DESC vk.friendship_statuses ;

-- Очищаем таблицу
TRUNCATE vk.friendship_statuses;

-- Вставляем значения статусов дружбы
INSERT INTO vk.friendship_statuses (name) VALUES
  ('Requested'),
  ('Confirmed'),
  ('Rejected');

-- Обновляем ссылки на статус в таблице vk.friendship
UPDATE vk.friendship SET status_id = FLOOR(1 + RAND() * 3);  
 

-- Таблица vk.communities
SELECT * FROM vk.communities;
DESC vk.communities ;

-- так как в базе данных 1000 пользователей, и сообществ 150 то можно не уменьшать количество сообществ
	-- Оставим только 20 групп
	-- DELETE FROM communities WHERE id > 20;
-- Обновляем ссылки на группы  для 20 групп
-- UPDATE communities_users SET community_id = FLOOR(1 + RAND() * 20); 


-- Таблица vk.communities_users
SELECT * FROM vk.communities_users;
SELECT * FROM vk.communities_users WHERE communities_id > 150; -- UPDATE vk.communities_users SET community_id = FLOOR(1 + RAND() * 150);

DESC vk.communities_users ;

-- обзор базы данных vk после коректировок

SHOW DATABASES ;
SHOW TABLES FROM vk;
-- communities
SELECT * FROM vk.communities LIMIT 10;
DESC vk.communities ;
-- communities_users
SELECT * FROM vk.communities_users LIMIT 10;
DESC vk.communities_users ;
-- friendship
SELECT * FROM vk.friendship WHERE requested_at > confirmed_at ; -- ?
DESC vk.friendship ;
-- friendship_statuses
SELECT * FROM vk.friendship_statuses ;
DESC vk.friendship_statuses ;
-- media
SELECT * FROM vk.media LIMIT 10;
DESC vk.media ;
-- media_types
SELECT * FROM vk.media_types ;
DESC vk.media_types ;
-- Таблица messages
SELECT * FROM vk.messages;
DESC vk.messages ;
-- profiles
SELECT * FROM vk.profiles LIMIT 100; -- коректировка birthday относительно vk.users.created_at
DESC vk.profiles ;
-- user_statuses
SELECT * FROM vk.user_statuses ;
DESC vk.user_statuses ;
-- users
SELECT * FROM vk.users LIMIT 100;
DESC vk.users ;

-- 2 Подобрать сервис который будет служить основной для вашей курсовой работы.
Netflix - зарегистрировался 10.05.2020(выбор известный сайт просмотра кино, сериалов, тв шоу, и др медиа)

-- 3 (по желанию) Предложить свою реализацию лайков и постов.

-- создать таблицу vk.posts (один ко многим - один пользователь много постов)
DROP TABLE IF EXISTS vk.posts;
CREATE TABLE vk.posts (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	user_id INT UNSIGNED NOT NULL PRIMARY KEY,
	body JSON,	-- {text: some_text, media: media_id OR https://dropbox/vk/some_media.some_media_type}
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP	

);

-- создание таблицы  vk.likes (многие ко многим)
-- version 1
	-- лайки хранить как пунктом like_id(если предусмотреть лайки и дизлайки) в таблицах и добавить в таблицу пункт счетчик лайков
	-- если есть только лайки то можно использовать BOOLEAN
	-- или для расширяемости сделать таблицу-справочник лайков 1 -лайк 2 - NULL 3- дизлайк
-- version 2
	-- с пунктами to_post_id, from_user_id (составной ключ)

DROP TABLE IF EXISTS vk.likes;
CREATE TABLE vk.likes (
	to_post_id INT UNSIGNED , -- to_user_id , to_media_id, to_messege_id и т.д
	from_user_id INT UNSIGNED,
	FOREIGN KEY (to_post_id) REFERENCES vk.posts (id) ON DELETE CASCADE,
	FOREIGN KEY (from_user_id) REFERENCES vk.users (id) ON DELETE CASCADE,
	PRIMARY KEY (to_post_id, from_user_id)	
);



