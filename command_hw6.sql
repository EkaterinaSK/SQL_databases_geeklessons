--cравнение лайков по полу

mysql> select count(id) as female_likes from likes where user_id IN (select user_id from profiles where gender = 'f');
+--------------+
| female_likes |
+--------------+
|           58 |
+--------------+
1 row in set (0.00 sec)

mysql> select count(id) as male_likes from likes where user_id IN (select user_id from profiles where gender = 'm');
+------------+
| male_likes |
+------------+
|         42 |
+------------+
1 row in set (0.00 sec)
-- таким образом, больше лайков ставили женщины (не разобралась, как красиво вывести сравнение);
-- смотрим самых молодых пользователей
mysql> select user_id, birthday  from profiles order by birthday desc limit 10;
+---------+------------+
| user_id | birthday   |
+---------+------------+
|      54 | 2020-03-01 |
|      35 | 2020-01-06 |
|      63 | 2019-02-21 |
|      42 | 2018-03-10 |
|      47 | 2016-11-16 |
|      84 | 2016-10-29 |
|      45 | 2016-09-12 |
|      61 | 2016-08-10 |
|      28 | 2016-06-17 |
|      98 | 2015-07-23 |
+---------+------------+
10 rows in set (0.00 sec)
--считаем полученные лайки по user_id
mysql> select count(id) from likes where (user_id = 54 OR user_id = 35 OR user_id = 63 OR user_id = 42 OR user_id = 47 OR user_id = 84 OR user_id= 45 OR user_ID = 61 OR user_id = 28 OR user_id = 98);
+-----------+
| count(id) |
+-----------+
|        11 |
+-----------+
1 row in set (0.00 sec)
--суммарно, 10 самых молодых пользователей получили 11 лайков
-- поотдельности выглядит так
mysql> select count(id) from likes where user_id = 35;
+-----------+
| count(id) |
+-----------+
|         3 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 54;
+-----------+
| count(id) |
+-----------+
|         1 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 63;
+-----------+
| count(id) |
+-----------+
|         0 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 42;
+-----------+
| count(id) |
+-----------+
|         1 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 47;
+-----------+
| count(id) |
+-----------+
|         1 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 84;
+-----------+
| count(id) |
+-----------+
|         4 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 45;
+-----------+
| count(id) |
+-----------+
|         0 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 61;
+-----------+
| count(id) |
+-----------+
|         0 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 28;
+-----------+
| count(id) |
+-----------+
|         1 |
+-----------+
1 row in set (0.00 sec)

mysql> select count(id) from likes where user_id = 98;
+-----------+
| count(id) |
+-----------+
|         0 |
+-----------+
1 row in set (0.00 sec)
--критериями активности берем наличие постов, друзей и получение лайков. Считаем самыми неактивными тех,
-- у кого аккаунт создан давно, а чего-то из вышеперечисленного нет.
mysql> select users.id, users.created_at 
from users 
left join likes on likes.user_id = users.id 
left join posts on posts.user_id = users.id 
left join friendship on friendship.user_id = users.id 
where likes.id IS NULL OR posts.id is null OR friendship.friend_id is null 
order by users.created_at limit 10;
+----+---------------------+
| id | created_at          |
+----+---------------------+
| 74 | 1970-05-22 23:27:28 |
| 83 | 1970-09-10 05:38:40 |
| 34 | 1971-06-11 15:35:32 |
| 53 | 1972-01-27 11:19:02 |
| 96 | 1973-02-24 19:02:02 |
| 96 | 1973-02-24 19:02:02 |
| 43 | 1974-01-26 21:12:31 |
| 99 | 1974-05-20 12:41:13 |
| 69 | 1974-06-10 04:13:32 |
| 12 | 1977-02-22 20:02:19 |
+----+---------------------+
10 rows in set (0.03 sec)



