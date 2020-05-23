/*Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение.
Агрегация данных
Работаем с БД vk и тестовыми данными, которые вы сгенерировали ранее:
 */


-- согласование данных photo_id
SELECT * FROM profiles;
SELECT * FROM media_types;
SELECT * FROM media;

UPDATE profiles SET photo_id =
	(SELECT id FROM media
	WHERE media.user_id = profiles.user_id AND media_type_id = 1 
	LIMIT 1)
;

/*1. Создать все необходимые внешние ключи и диаграмму отношений.
*/
USE vk;

-- установка связаных ключей
DESC vk.users;

SHOW TABLES;

ALTER TABLE users MODIFY COLUMN status_id INT UNSIGNED;

ALTER TABLE vk.users
	ADD CONSTRAINT users_status_id_fk
	FOREIGN KEY (status_id) REFERENCES user_statuses(id)
		ON DELETE SET NULL;

DESC profiles;

ALTER TABLE profiles 
	ADD CONSTRAINT profiles_user_id_fk
	FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE,
	ADD CONSTRAINT profiles_photo_id_fk
	FOREIGN KEY (photo_id) REFERENCES media(id)
		ON DELETE SET NULL;
	
SHOW TABLES;

DESC messages ;

ALTER TABLE messages 
	MODIFY COLUMN from_user_id INT UNSIGNED,
	MODIFY COLUMN to_user_id INT UNSIGNED;

ALTER TABLE messages 
	ADD CONSTRAINT messages_from_user_id_fk
	FOREIGN KEY (from_user_id) REFERENCES users(id)
		ON DELETE SET NULL,
	ADD CONSTRAINT messages_to_user_id_fk
	FOREIGN KEY (to_user_id) REFERENCES users(id)
		ON DELETE SET NULL;

	
	
DESC media;
desc users;
DESC media_types ;

ALTER TABLE media 
	MODIFY COLUMN user_id INT UNSIGNED,
	MODIFY COLUMN media_type_id INT UNSIGNED;

ALTER TABLE media 
	ADD CONSTRAINT media_user_id_fk
	FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE SET NULL,
	ADD CONSTRAINT media_media_type_id_fk
	FOREIGN KEY (media_type_id) REFERENCES media_types(id)
		ON DELETE CASCADE;
	

DESC communities_users ;
SELECT * FROM communities_users;
DESC communities ;



DESC communities_users ;

ALTER TABLE communities_users 
	ADD CONSTRAINT communities_users_communities_id_fk
	FOREIGN KEY (communities_id) REFERENCES communities(id)
		ON DELETE CASCADE,
	ADD CONSTRAINT communities_users_user_id_fk
	FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE;
	


DESC friendship_statuses ;
DESC friendship ;

ALTER TABLE vk.friendship 
	MODIFY COLUMN user_id INT UNSIGNED ,
	MODIFY COLUMN friend_id INT UNSIGNED NULL ,
	MODIFY COLUMN status_id INT UNSIGNED NULL;

ALTER TABLE vk.friendship 
	ADD CONSTRAINT friendship_user_id_fk
	FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE CASCADE,
	ADD CONSTRAINT friendship_friend_id_fk
	FOREIGN KEY (friend_id) REFERENCES users(id)
		ON DELETE CASCADE,
	ADD CONSTRAINT friendship_status_id_fk
	FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
		ON DELETE CASCADE;
	

DESC vk.likes ;
DESC target_types ;

	
ALTER TABLE likes 
	MODIFY COLUMN user_id INT UNSIGNED;
	
ALTER TABLE vk.likes 
	ADD CONSTRAINT likes_user_id_fk
	FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE SET NULL,
	ADD CONSTRAINT likes_target_type_id_fk
	FOREIGN KEY (target_type_id) REFERENCES target_types(id)
		ON DELETE CASCADE;

DESC vk.posts ;

ALTER TABLE posts 
	MODIFY COLUMN user_id INT UNSIGNED;
	
ALTER TABLE vk.posts 
	ADD CONSTRAINT posts_user_id_fk
	FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE SET NULL,
	ADD CONSTRAINT posts_community_id_fk
	FOREIGN KEY (community_id) REFERENCES communities(id)
		ON DELETE SET NULL,
	ADD CONSTRAINT posts_media_id_fk
	FOREIGN KEY (media_id) REFERENCES media(id)
		ON DELETE SET NULL;






/*2. Создать и заполнить таблицы лайков и постов.
*/
-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

-- Заполняем лайки
INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 1000)), 
    FLOOR(1 + (RAND() * 1000)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

SELECT COUNT(*) FROM messages;
SELECT * FROM users;
SELECT * FROM media;
SELECT * FROM target_types ;

SELECT * FROM likes WHERE target_type_id = 1;
UPDATE vk.likes SET  target_id = FLOOR(1 + (RAND() * 3000)) WHERE target_type_id = 1;
SELECT * FROM likes LIMIT 10;


-- Создадим таблицу постов
DROP TABLE IF EXISTS vk.posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  views_counter INT UNSIGNED DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- fulldb18-05-2020 19-10.sql

SELECT * FROM posts;

SELECT COUNT(*) FROM communities ;
SELECT COUNT(*) FROM media;

UPDATE posts 
	SET user_id = FLOOR(1 + (RAND() * 1000));
UPDATE posts 
	SET community_id =FLOOR(1 + (RAND() * 150));
UPDATE posts 
	SET media_id = FLOOR(1 + (RAND() * 1000));
	
/*3. Подсчитать общее количество лайков десяти самым молодым пользователям 
(сколько лайков получили 10 самых молодых пользователей).
*/ 


DESC profiles ;
DESC likes ;

SELECT user_id, TIMESTAMPDIFF(YEAR,birthday,NOW()) AS user_age
FROM profiles 
	ORDER BY user_age 
	LIMIT 10; -- id и возраст 10 самых молодых пользователей
	
SELECT user_id , 
FROM profiles  
	ORDER BY TIMESTAMPDIFF(YEAR,birthday,NOW()) 
	LIMIT 10; -- id 10 самых молодых пользователей
	
SELECT * FROM target_types ;


SELECT COUNT(likes.target_id) 
FROM likes, profiles , target_types 
	WHERE likes.target_id = profiles.user_id 
		AND target_types.name = 'users'
	ORDER BY TIMESTAMPDIFF(YEAR,birthday,NOW()) 
	LIMIT 10;


desc likes ;
SELECT * FROM target_types tt ;

SELECT COUNT(id) AS sum_likes, target_id 
FROM likes 
	WHERE target_type_id = (
		SELECT id FROM target_types WHERE name = 'users'
	) 
	AND target_id IN (
		SELECT user_id 
		FROM profiles p2 
			ORDER BY TIMESTAMPDIFF(YEAR,birthday,NOW())
	)
	GROUP BY target_id
	ORDER BY sum_likes
	LIMIT 10;

/*Задание 3:
В решении вы используете неявный JOIN, 
но есть ошибка в логике - не будут учтены пользователи, 
у которых нет дайков, поэтому результат неверен.
*/

SELECT user_id, 
	TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age ,
	(SELECT COUNT(target_id) FROM likes l2 
		WHERE target_type_id = (SELECT id FROM target_types WHERE name LIKE 'users') 
			AND target_id = p.user_id
	) AS likes
FROM profiles p 
	ORDER BY age
	LIMIT 10;

/*4. Определить кто больше поставил лайков (вего) 
 - мужчины или женщины?
*/ 
DESC likes ;

SELECT profiles.user_id, likes.user_id, profiles.gender 
FROM profiles, likes 
	WHERE profiles.user_id = likes.user_id 
		AND profiles.gender = 'm'; -- пользователи поставившие лайки с gender = 'm'
		
SELECT profiles.user_id, likes.user_id, profiles.gender 
FROM profiles, likes 
	WHERE profiles.user_id = likes.user_id 
		AND profiles.gender = 'w'; -- пользователи поставившие лайки с gender = 'w'
		
SELECT COUNT(user_id) 
FROM likes 
	WHERE  user_id IN (
		SELECT user_id  FROM profiles AND profiles.gender = 'm'
	);

SELECT COUNT(profiles.user_id) 
FROM profiles, likes  
	WHERE profiles.user_id = likes.user_id 
		AND profiles.gender = 'm'; -- количесвто лайков gender = 'm'
		
SELECT COUNT(profiles.user_id) 
FROM profiles, likes  
	WHERE profiles.user_id = likes.user_id 
		AND profiles.gender = 'w'; -- количество лайков gender = 'w'

SELECT (
	SELECT COUNT(profiles.user_id) 
	FROM profiles, likes  
		WHERE profiles.user_id = likes.user_id 
			AND profiles.gender = 'm'
	) AS 'likes in usergender = m',
	(
	SELECT COUNT(profiles.user_id) 
	FROM profiles, likes  
		WHERE profiles.user_id = likes.user_id 
			AND profiles.gender = 'w'
	) AS 'likes in usergender = w'
FROM profiles,likes 
	LIMIT 1;



/*Задание 4:
Хорошо, но с группировкой можно сделать проще.
*/


SELECT COUNT(likes.user_id) AS likes, profiles.gender 
FROM profiles, likes 
	WHERE profiles.user_id = likes.user_id 
	GROUP BY profiles.gender; 

desc likes ;
-- через вложенные запросы

SELECT COUNT(user_id) AS likes,
	(SELECT gender FROM profiles WHERE user_id = l.user_id ) AS gender
FROM likes l 
	WHERE l.user_id IN (SELECT user_id FROM profiles p2 )
	GROUP BY gender ;




/*5. Найти 10 пользователей, которые проявляют наименьшую активность в
использовании социальной сети
(критерии активности необходимо определить самостоятельно).
*/
-- критерий активности( наличие: сообщений, лайков, постов, друзей, медиа, колическо групп у пользователя)

-- наименьшее количество от пользователя: сообщений, лаков, постов, друзей, медиа, групп

SELECT user_id, COUNT(id) AS users_likes 
FROM likes 
	GROUP BY user_id
	ORDER BY users_likes;	-- количество лайков у пользователя

DESC messages ;

SELECT from_user_id, COUNT(id) AS users_messages 
FROM messages
	GROUP BY from_user_id
	ORDER BY users_messages;	-- количество сообщений от пользователя

DESC posts ;

SELECT user_id, COUNT(id) AS users_posts 
FROM posts
	GROUP BY user_id
	ORDER BY users_posts;	-- количество постов пользователя

DESC friendship;
SELECT * FROM friendship_statuses fs ;

SELECT user_id, 
	COUNT(status_id = (
		SELECT fs.id WHERE fs.name = 'Confirmed' )
	) AS users_friendship 
FROM friendship, friendship_statuses AS fs
	GROUP BY user_id
	ORDER BY users_friendship;	-- количество подтвержденной дружбы пользователя

DESC media;

SELECT user_id, COUNT(id) AS users_media
FROM media
	GROUP BY user_id
	ORDER BY users_media;	-- количество загруженых медиа пользователя

DESC communities ;
DESC communities_users ;

SELECT user_id, COUNT(communities_id) AS users_community
FROM communities_users 
	GROUP BY user_id
	ORDER BY users_community ;	-- количество груп пользователя


