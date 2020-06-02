/*1. Проанализировать какие запросы могут выполняться наиболее часто 
 * в процессе работы приложения и добавить необходимые индексы.
 */

-- индексы на основе поиска в соц.сети vk:
-- (страна и город, пол, возраст от до, семейное положение)
DESC users;
DESC profiles;
DROP INDEX users_email_uq ON users;
CREATE UNIQUE INDEX users_email_uq ON users(email);

DROP INDEX users_phone_uq ON users;
CREATE UNIQUE INDEX users_phone_uq ON users(phone);

DROP INDEX users_status_id_idx ON users;
CREATE INDEX users_status_id_idx ON users(status_id);

DROP INDEX messages_from_user_id_to_user_id_idx ON messages;
CREATE INDEX messages_from_user_id_to_user_id_idx 
	ON messages (from_user_id, to_user_id);

DROP INDEX profiles_country_city_idx ON profiles;
CREATE INDEX profiles_country_city_idx 
	ON profiles (country, city);

DROP INDEX profiles_birthday_gender_idx ON profiles;
CREATE INDEX profiles_birthday_gender_idx 
	ON profiles (birthday, gender);



/*2. Задание на оконные функции
Построить запрос, который будет выводить следующие столбцы:
имя группы
среднее количество пользователей в группах - 
самый молодой пользователь в группе
самый старший пользователь в группе
общее количество пользователей в группе
всего пользователей в системе

отношение в процентах 
(общее количество пользователей в группе / всего пользователей в системе) * 100
*/
SELECT * FROM communities_users ;

SELECT MAX(p.birthday )
FROM profiles p ;

SELECT MIN(p.birthday )
FROM profiles p ;

SELECT *
FROM profiles p 
	ORDER BY p.birthday ;

SELECT SUM(COUNT(cu.user_id)) / COUNT(communities_id )
FROM communities_users cu
	GROUP BY cu.communities_id ;

SELECT COUNT(cu.user_id)
FROM communities_users cu
	GROUP BY cu.communities_id ;

SELECT DISTINCT c.name ,
	(SELECT COUNT(DISTINCT cu.user_id) FROM communities_users cu)/
	(SELECT COUNT(DISTINCT cu.communities_id)FROM communities_users cu) AS average_users_in_community,
	MIN(p.birthday) OVER(PARTITION BY cu.communities_id) AS min_birthday_in_community,
	MAX(p.birthday) OVER(PARTITION BY cu.communities_id) AS max_birthday_in_community,
	COUNT(cu.user_id) OVER(PARTITION BY cu.communities_id) AS users_in_communities,
	COUNT(cu.user_id) OVER() AS total_in_communities,
  	COUNT(p.user_id) OVER() AS total_users,
  	(COUNT(cu.user_id) OVER() / COUNT(p.user_id) OVER()) * 100 AS '%%'
FROM communities c
	JOIN communities_users cu
		ON c.id = cu.communities_id
	RIGHT JOIN profiles p
		ON cu.user_id = p.user_id ;
	
