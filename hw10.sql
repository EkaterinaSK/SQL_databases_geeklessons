mysql> CREATE INDEX users_fullname_idx ON users(first_name, last_name);
Query OK, 0 rows affected (0.25 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX users_homeland_idx ON users(city);
Query OK, 0 rows affected, 1 warning (0.12 sec)
Records: 0  Duplicates: 0  Warnings: 1
mysql> CREATE INDEX communities_groupname_idx ON communities(name);
Query OK, 0 rows affected (0.08 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX profiles_age_idx on profiles(birthday);
Query OK, 0 rows affected (0.07 sec)
Records: 0  Duplicates: 0  Warnings: 0
--- Мне показалось, что наиболее частые запросы это запросы это поиск людей по ФИО (поэтому первый индекс на имя и фамилию),
-- поиск по городам (поэтому второй индекс), поиск сообществ по названиям (третий) и поиск по возрасту (четвертый)

mysql> select  DISTINCT communities.name,
    -> 	   COUNT(communities_users.user_id) OVER ()/COUNT(communities.name) OVER () as average_users,
    ->     FIRST_VALUE(communities_users.user_id) OVER (PARTITION BY profiles.user_id ORDER by profiles.age) as youngest,
    ->     LAST_VALUE(communities_users.user_id) OVER (PARTITION BY profiles.user_id ORDER by profiles.age) as oldest,
    ->     COUNT(communities_users.user_id) OVER w as total_users_in_group,
    ->     COUNT(communities_users.user_id) OVER() as total_users,
    ->     COUNT(communities_users.user_id) OVER w / COUNT(communities_users.user_id) OVER () * 100 as '%%'
    ->     FROM (communities_users
    ->     JOIN communities on communities.id = communities_users.community_id
    ->     JOIN profiles on communities_users.user_id = profiles.user_id)
    ->     WINDOW w as (PARTITION BY communities_users.user_id);
+----------------+---------------+----------+--------+----------------------+-------------+--------+
| name           | average_users | youngest | oldest | total_users_in_group | total_users | %%     |
+----------------+---------------+----------+--------+----------------------+-------------+--------+
| nulla          |        1.0000 |        1 |      1 |                    1 |         100 | 1.0000 |
| est            |        1.0000 |        4 |      4 |                    1 |         100 | 1.0000 |
| eos            |        1.0000 |        5 |      5 |                    1 |         100 | 1.0000 |
| et             |        1.0000 |        9 |      9 |                    1 |         100 | 1.0000 |
| voluptatum     |        1.0000 |       10 |     10 |                    2 |         100 | 2.0000 |
| necessitatibus |        1.0000 |       10 |     10 |                    2 |         100 | 2.0000 |
| esse           |        1.0000 |       11 |     11 |                    1 |         100 | 1.0000 |
| itaque         |        1.0000 |       12 |     12 |                    1 |         100 | 1.0000 |
| eaque          |        1.0000 |       13 |     13 |                    1 |         100 | 1.0000 |
| non            |        1.0000 |       14 |     14 |                    1 |         100 | 1.0000 |
| facere         |        1.0000 |       15 |     15 |                    1 |         100 | 1.0000 |
| neque          |        1.0000 |       17 |     17 |                    1 |         100 | 1.0000 |
| laborum        |        1.0000 |       19 |     19 |                    1 |         100 | 1.0000 |
| enim           |        1.0000 |       20 |     20 |                    1 |         100 | 1.0000 |
| voluptate      |        1.0000 |       21 |     21 |                    1 |         100 | 1.0000 |
| nostrum        |        1.0000 |       22 |     22 |                    3 |         100 | 3.0000 |
| natus          |        1.0000 |       22 |     22 |                    3 |         100 | 3.0000 |
| quas           |        1.0000 |       22 |     22 |                    3 |         100 | 3.0000 |
| ratione        |        1.0000 |       25 |     25 |                    1 |         100 | 1.0000 |
| laudantium     |        1.0000 |       26 |     26 |                    1 |         100 | 1.0000 |
| quia           |        1.0000 |       27 |     27 |                    2 |         100 | 2.0000 |
| asperiores     |        1.0000 |       27 |     27 |                    2 |         100 | 2.0000 |
| consequatur    |        1.0000 |       28 |     28 |                    2 |         100 | 2.0000 |
| provident      |        1.0000 |       28 |     28 |                    2 |         100 | 2.0000 |
| ullam          |        1.0000 |       29 |     29 |                    1 |         100 | 1.0000 |
| officia        |        1.0000 |       31 |     31 |                    1 |         100 | 1.0000 |
| ex             |        1.0000 |       32 |     32 |                    3 |         100 | 3.0000 |
| odit           |        1.0000 |       32 |     32 |                    3 |         100 | 3.0000 |
| aut            |        1.0000 |       32 |     32 |                    3 |         100 | 3.0000 |
| ab             |        1.0000 |       33 |     33 |                    1 |         100 | 1.0000 |
| at             |        1.0000 |       35 |     35 |                    1 |         100 | 1.0000 |
| omnis          |        1.0000 |       36 |     36 |                    3 |         100 | 3.0000 |
| libero         |        1.0000 |       36 |     36 |                    3 |         100 | 3.0000 |
| aspernatur     |        1.0000 |       36 |     36 |                    3 |         100 | 3.0000 |
| adipisci       |        1.0000 |       37 |     37 |                    1 |         100 | 1.0000 |
| id             |        1.0000 |       38 |     38 |                    2 |         100 | 2.0000 |
| voluptatem     |        1.0000 |       38 |     38 |                    2 |         100 | 2.0000 |
| quis           |        1.0000 |       39 |     39 |                    1 |         100 | 1.0000 |
| praesentium    |        1.0000 |       40 |     40 |                    2 |         100 | 2.0000 |
| similique      |        1.0000 |       40 |     40 |                    2 |         100 | 2.0000 |
| veritatis      |        1.0000 |       41 |     41 |                    1 |         100 | 1.0000 |
| commodi        |        1.0000 |       42 |     42 |                    1 |         100 | 1.0000 |
| ipsum          |        1.0000 |       43 |     43 |                    1 |         100 | 1.0000 |
| blanditiis     |        1.0000 |       44 |     44 |                    2 |         100 | 2.0000 |
| molestiae      |        1.0000 |       44 |     44 |                    2 |         100 | 2.0000 |
| laboriosam     |        1.0000 |       46 |     46 |                    1 |         100 | 1.0000 |
| tenetur        |        1.0000 |       52 |     52 |                    1 |         100 | 1.0000 |
| labore         |        1.0000 |       53 |     53 |                    6 |         100 | 6.0000 |
| deleniti       |        1.0000 |       53 |     53 |                    6 |         100 | 6.0000 |
| quasi          |        1.0000 |       53 |     53 |                    6 |         100 | 6.0000 |
| sunt           |        1.0000 |       53 |     53 |                    6 |         100 | 6.0000 |
| cum            |        1.0000 |       53 |     53 |                    6 |         100 | 6.0000 |
| mollitia       |        1.0000 |       53 |     53 |                    6 |         100 | 6.0000 |
| ut             |        1.0000 |       54 |     54 |                    3 |         100 | 3.0000 |
| reiciendis     |        1.0000 |       54 |     54 |                    3 |         100 | 3.0000 |
| autem          |        1.0000 |       54 |     54 |                    3 |         100 | 3.0000 |
| dolorum        |        1.0000 |       55 |     55 |                    2 |         100 | 2.0000 |
| corrupti       |        1.0000 |       55 |     55 |                    2 |         100 | 2.0000 |
| inventore      |        1.0000 |       56 |     56 |                    1 |         100 | 1.0000 |
| doloribus      |        1.0000 |       57 |     57 |                    3 |         100 | 3.0000 |
| tempore        |        1.0000 |       57 |     57 |                    3 |         100 | 3.0000 |
| ea             |        1.0000 |       57 |     57 |                    3 |         100 | 3.0000 |
| saepe          |        1.0000 |       59 |     59 |                    1 |         100 | 1.0000 |
| perspiciatis   |        1.0000 |       60 |     60 |                    1 |         100 | 1.0000 |
| quam           |        1.0000 |       61 |     61 |                    1 |         100 | 1.0000 |
| architecto     |        1.0000 |       62 |     62 |                    1 |         100 | 1.0000 |
| rerum          |        1.0000 |       63 |     63 |                    1 |         100 | 1.0000 |
| nihil          |        1.0000 |       64 |     64 |                    2 |         100 | 2.0000 |
| repudiandae    |        1.0000 |       64 |     64 |                    2 |         100 | 2.0000 |
| accusamus      |        1.0000 |       65 |     65 |                    1 |         100 | 1.0000 |
| cupiditate     |        1.0000 |       66 |     66 |                    1 |         100 | 1.0000 |
| amet           |        1.0000 |       68 |     68 |                    2 |         100 | 2.0000 |
| iusto          |        1.0000 |       68 |     68 |                    2 |         100 | 2.0000 |
| quo            |        1.0000 |       69 |     69 |                    1 |         100 | 1.0000 |
| molestias      |        1.0000 |       70 |     70 |                    1 |         100 | 1.0000 |
| nam            |        1.0000 |       71 |     71 |                    1 |         100 | 1.0000 |
| facilis        |        1.0000 |       72 |     72 |                    1 |         100 | 1.0000 |
| ad             |        1.0000 |       73 |     73 |                    2 |         100 | 2.0000 |
| voluptas       |        1.0000 |       73 |     73 |                    2 |         100 | 2.0000 |
| maxime         |        1.0000 |       75 |     75 |                    2 |         100 | 2.0000 |
| quae           |        1.0000 |       75 |     75 |                    2 |         100 | 2.0000 |
| nemo           |        1.0000 |       81 |     81 |                    1 |         100 | 1.0000 |
| consectetur    |        1.0000 |       82 |     82 |                    1 |         100 | 1.0000 |
| dolor          |        1.0000 |       83 |     83 |                    1 |         100 | 1.0000 |
| vitae          |        1.0000 |       84 |     84 |                    1 |         100 | 1.0000 |
| in             |        1.0000 |       86 |     86 |                    2 |         100 | 2.0000 |
| eius           |        1.0000 |       86 |     86 |                    2 |         100 | 2.0000 |
| qui            |        1.0000 |       89 |     89 |                    2 |         100 | 2.0000 |
| odio           |        1.0000 |       89 |     89 |                    2 |         100 | 2.0000 |
| corporis       |        1.0000 |       90 |     90 |                    3 |         100 | 3.0000 |
| dignissimos    |        1.0000 |       90 |     90 |                    3 |         100 | 3.0000 |
| unde           |        1.0000 |       90 |     90 |                    3 |         100 | 3.0000 |
| culpa          |        1.0000 |       92 |     92 |                    3 |         100 | 3.0000 |
| explicabo      |        1.0000 |       92 |     92 |                    3 |         100 | 3.0000 |
| iure           |        1.0000 |       92 |     92 |                    3 |         100 | 3.0000 |
| magnam         |        1.0000 |       94 |     94 |                    1 |         100 | 1.0000 |
| temporibus     |        1.0000 |       96 |     96 |                    2 |         100 | 2.0000 |
| incidunt       |        1.0000 |       96 |     96 |                    2 |         100 | 2.0000 |
| accusantium    |        1.0000 |       98 |     98 |                    1 |         100 | 1.0000 |
| nisi           |        1.0000 |      100 |    100 |                    1 |         100 | 1.0000 |
+----------------+---------------+----------+--------+----------------------+-------------+--------+
100 rows in set (0.01 sec)
--- я неправильно вывела самого молодого и самого старого пользователей. По идее, если брать обычные функции,
--то выглядит поиск молодого и старого пользователей как-то так (на примере молодого) select communities_users.user_id
   -- -> from communities_users
    -- -> join profiles on profiles.user_id=communities_users.user_id
   -- -> order by profiles.age limit 1;
   -- соот-но я беру первое и последнее значение в оконной функции из партиции профайлов, отсортированной по возрасту. 
   -- но "что-то пошло не так".
   -- да и такое ощущение, что среднее кол-во пользователей в группах я неверно посчитала.
