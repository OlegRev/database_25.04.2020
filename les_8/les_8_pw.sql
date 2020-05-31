/*3. Подсчитать общее количество лайков десяти самым молодым пользователям 
(сколько лайков получили 10 самых молодых пользователей).
*/ 

SELECT user_id, 
	 birthday ,
	(SELECT COUNT(target_id) FROM likes l2 
		WHERE target_type_id = (
			SELECT id FROM target_types WHERE name LIKE 'users'
		) AND target_id = p.user_id
	) AS likes
FROM profiles p 
	ORDER BY birthday DESC
	LIMIT 10;

SELECT SUM(likes) 
FROM(SELECT user_id, 
	birthday ,
	(SELECT COUNT(target_id) FROM likes l2 
		WHERE target_type_id = 2
			AND target_id = p.user_id
	) AS likes
FROM profiles p 
	ORDER BY birthday DESC
	LIMIT 10) AS user_likes;

-- JOIN

SELECT p.user_id, 
	p.birthday,
	COUNT(l.target_id) AS likes
FROM profiles p
	LEFT JOIN likes l
	ON l.target_id = p.user_id
		AND l.target_type_id = 2 
	GROUP BY p.user_id 
		ORDER BY p.birthday DESC
	LIMIT 10;

SELECT SUM(likes ) FROM (SELECT p.user_id, 
	p.birthday,
	COUNT(l.target_id) AS likes
FROM profiles p
	LEFT JOIN likes l
	ON l.target_id = p.user_id
		AND l.target_type_id = 2 
	GROUP BY p.user_id 
		ORDER BY p.birthday DESC
	LIMIT 10) AS user_likes; 

/*4. Определить кто больше поставил лайков (вего) 
 - мужчины или женщины?
*/ 

SELECT COUNT(user_id) AS likes,
	(SELECT gender FROM profiles WHERE user_id = l.user_id ) AS gender
FROM likes l 
	WHERE l.user_id IN (SELECT user_id FROM profiles p2 )
	GROUP BY gender ;

-- JOIN

SELECT COUNT(likes.user_id) AS likes, profiles.gender 
FROM profiles
	JOIN likes 
		ON profiles.user_id = likes.user_id 
	GROUP BY profiles.gender; 

/*5. Найти 10 пользователей, которые проявляют наименьшую активность в
использовании социальной сети
(критерии активности необходимо определить самостоятельно).
*/

SELECT users.id,
  	CONCAT(first_name, ' ', last_name) AS user_name, 
	(SELECT COUNT(*) FROM likes l WHERE l.user_id = users.id) + 
	(SELECT COUNT(*) FROM media m WHERE m.user_id = users.id) + 
	(SELECT COUNT(*) FROM messages ms WHERE ms.from_user_id = users.id) +
	(SELECT COUNT(*) FROM posts p WHERE p.user_id = users.id
	) AS overall_activity 
FROM users
GROUP BY users.id
	  ORDER BY overall_activity
	  LIMIT 10;
	  
-- JOIN
	 
SELECT 
	u.id,
	CONCAT(u.first_name, ' ', u.last_name) AS user_name,
	COUNT(DISTINCT l.id ) +
	COUNT(DISTINCT m.id ) +
	COUNT(DISTINCT ms.id ) +
	COUNT(DISTINCT p.id ) AS overall_activity
FROM users u 
	LEFT JOIN likes l
		ON l.user_id = u.id
	LEFT JOIN media m
		ON m.user_id = u.id
	LEFT JOIN messages ms
		ON ms.from_user_id = u.id
	LEFT JOIN posts p
		ON p.user_id = u.id
GROUP BY u.id, user_name
ORDER BY overall_activity
	LIMIT 10;
