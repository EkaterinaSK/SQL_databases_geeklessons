'База служит для консолидации информации по происшествиям и ходу их расследований'

'индекс поиска по клиентам, вовлеченным в происшествия'
mysql> CREATE INDEX clients_idx on accidents(client_id);
Query OK, 0 rows affected (0.14 sec)
Records: 0  Duplicates: 0  Warnings: 0

'индекс по ответственным предприятиям'
mysql> CREATE INDEX responsiblities_id on investigation(resp_un_id);
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

'проверяем индексы'
mysql> show index from *;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '*' at line 1
mysql> show index from accidents;
+-----------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| accidents |          0 | PRIMARY     |            1 | ac_id       | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| accidents |          1 | clients_idx |            1 | client_id   | A         |          84 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-----------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
2 rows in set (0.02 sec)

mysql> show index from investigation;
+---------------+------------+--------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table         | Non_unique | Key_name           | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+---------------+------------+--------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| investigation |          0 | PRIMARY            |            1 | inv_id      | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| investigation |          1 | responsiblities_id |            1 | resp_un_id  | A         |           8 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+---------------+------------+--------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
2 rows in set (0.01 sec)

'выборка расследований(происшествий) по ответственным предприятиям'
mysql> select 
r.unit_name as 'ответственный', 
count(i.inv_id) as 'количество происшествий' 
from investigation as i JOIN responsible_units as r ON r.unit_id = i.resp_un_id GROUP BY r.unit_name;
+----------------------------+-----------------------------------------------+
| ответственный              | количество происшествий                       |
+----------------------------+-----------------------------------------------+
| не определено              |                                            19 |
| Management company         |                                            27 |
| Ground hadling             |                                            25 |
| Catering                   |                                            27 |
| Slot allocation            |                                            22 |
| Information technologies   |                                            23 |
| Training                   |                                            30 |
| Passenger dept             |                                            27 |
+----------------------------+-----------------------------------------------+
8 rows in set (0.00 sec)

'выборка критических инцидентов, расследование по которым завершено с признанием факта инцедента, но корректирующих мер не предложено'
select 
  a.ac_id as 'id',
  a.accident_name as 'наименование инцидента'
  from accidents as a
  JOIN accident_types 
  ON a.accident_type_id = accident_types.type_id
  JOIN investigation
  ON a.invest_id = investigation.inv_id
  where (accident_types.is_critical = 1 and investigation.have_measures = 0 and a.status = 2);
+-----+---------------------------------------------+
| id  | наименование инцидента                      |
+-----+---------------------------------------------+
|  10 | odit                                        |
|  13 | magnam                                      |
|  16 | quae                                        |
|  18 | sit                                         |
|  46 | quisquam                                    |
|  57 | itaque                                      |
|  59 | eum                                         |
|  77 | voluptatem                                  |
|  85 | non                                         |
|  94 | voluptates                                  |
| 103 | blanditiis                                  |
| 146 | omnis                                       |
| 153 | qui                                         |
| 182 | et                                          |
| 198 | voluptatibus                                |
+-----+---------------------------------------------+
15 rows in set (0.00 sec)

'оконная функция по выводу клиентов, по которым были проблемы и % проблем данных клиентов от общего числа проблем'
mysql> select DISTINCT clients.client_name,
    ->     COUNT( accidents.client_id) OVER w AS 'clients have accidents',
    ->     COUNT(accidents.client_id) OVER w / COUNT(accidents.ac_id) OVER () *100 AS "%% problem"
    ->     FROM clients
    ->     JOIN accidents on accidents.client_id = clients.client_id
    ->  WINDOW w as (PARTITION BY accidents.client_id);
+--------------+------------------------+------------+
| client_name  | clients have accidents | %% problem |
+--------------+------------------------+------------+
| ipsum        |                      1 |     0.5000 |
| impedit      |                      2 |     1.0000 |
| soluta       |                      2 |     1.0000 |
| dignissimos  |                      2 |     1.0000 |
| enim         |                      3 |     1.5000 |
| voluptas     |                      2 |     1.0000 |
| iusto        |                      1 |     0.5000 |
| omnis        |                      1 |     0.5000 |
| tempora      |                      2 |     1.0000 |
| rerum        |                      4 |     2.0000 |
| repellat     |                      2 |     1.0000 |
| nobis        |                      3 |     1.5000 |
| consectetur  |                      3 |     1.5000 |
| quas         |                      2 |     1.0000 |
| ex           |                      2 |     1.0000 |
| adipisci     |                      4 |     2.0000 |
| repellendus  |                      3 |     1.5000 |
| non          |                      1 |     0.5000 |
| earum        |                      3 |     1.5000 |
| corporis     |                      4 |     2.0000 |
| distinctio   |                      1 |     0.5000 |
| qui          |                      1 |     0.5000 |
| est          |                      1 |     0.5000 |
| sed          |                      3 |     1.5000 |
| consequatur  |                      1 |     0.5000 |
| dolorem      |                      2 |     1.0000 |
| debitis      |                      2 |     1.0000 |
| totam        |                      1 |     0.5000 |
| quasi        |                      3 |     1.5000 |
| laudantium   |                      4 |     2.0000 |
| ea           |                      1 |     0.5000 |
| iure         |                      2 |     1.0000 |
| quaerat      |                      3 |     1.5000 |
| culpa        |                      3 |     1.5000 |
| voluptatum   |                      4 |     2.0000 |
| aut          |                      1 |     0.5000 |
| velit        |                      1 |     0.5000 |
| nostrum      |                      3 |     1.5000 |
| temporibus   |                      2 |     1.0000 |
| corporis     |                      5 |     2.5000 |
| similique    |                      3 |     1.5000 |
| esse         |                      3 |     1.5000 |
| quibusdam    |                      3 |     1.5000 |
| suscipit     |                      1 |     0.5000 |
| molestias    |                      1 |     0.5000 |
| at           |                      2 |     1.0000 |
| molestias    |                      3 |     1.5000 |
| sint         |                      2 |     1.0000 |
| sit          |                      3 |     1.5000 |
| repellat     |                      3 |     1.5000 |
| quis         |                      5 |     2.5000 |
| est          |                      2 |     1.0000 |
| nesciunt     |                      4 |     2.0000 |
| occaecati    |                      1 |     0.5000 |
| perferendis  |                      1 |     0.5000 |
| sed          |                      1 |     0.5000 |
| laborum      |                      1 |     0.5000 |
| id           |                      5 |     2.5000 |
| repudiandae  |                      4 |     2.0000 |
| voluptatem   |                      1 |     0.5000 |
| vitae        |                      1 |     0.5000 |
| unde         |                      3 |     1.5000 |
| blanditiis   |                      3 |     1.5000 |
| neque        |                      5 |     2.5000 |
| earum        |                      4 |     2.0000 |
| molestias    |                      2 |     1.0000 |
| quam         |                      2 |     1.0000 |
| sit          |                      4 |     2.0000 |
| iure         |                      3 |     1.5000 |
| dolor        |                      2 |     1.0000 |
| aliquid      |                      4 |     2.0000 |
| rerum        |                      2 |     1.0000 |
| totam        |                      3 |     1.5000 |
| consectetur  |                      1 |     0.5000 |
| quia         |                      2 |     1.0000 |
| voluptatibus |                      1 |     0.5000 |
| fugit        |                      2 |     1.0000 |
| et           |                      5 |     2.5000 |
+--------------+------------------------+------------+
78 rows in set (0.01 sec)

'подсчет инцидентов по категориям клиентов'
mysql> select DISTINCT client_types.type_name,
    ->     COUNT(DISTINCT accidents.client_id)  AS 'clients have accidents'
    ->     FROM (clients
    ->     JOIN accidents ON accidents.client_id = clients.client_id
    ->     JOIN client_types ON client_types.type_id = clients.client_type_id)
    ->     Group by client_types.type_name;
+------------------------------------------------------+------------------------+
| type_name                                            | clients have accidents |
+------------------------------------------------------+------------------------+
| авиакомпании                                         |                     10 |
| арендаторы                                           |                      7 |
| гос.органы                                           |                      5 |
| кандидаты                                            |                      9 |
| контрагенты                                          |                     10 |
| Общий                                                |                     12 |
| пассажиры                                            |                      7 |
| посетители                                           |                      6 |
| сотрудники                                           |                      6 |
| студенты целевой подготовки                          |                     12 |
+------------------------------------------------------+------------------------+
10 rows in set (0.00 sec)

'запрос на количество расследований в производстве у ответственных за расследование'
mysql> select i.invest_id, i.invest_name,
    -> COUNT(inv.inv_id) as 'inv in progress'
    -> from investigators as i
    -> JOIN investigation as inv
    -> ON i.invest_id = inv.resp_inv
    -> where inv.inv_status = 1
    -> GROUP BY i.invest_id, i.invest_name;
+-----------+--------------+-----------------+
| invest_id | invest_name  | inv in progress |
+-----------+--------------+-----------------+
|        45 | Becker       |               4 |
|         2 | Bednar       |               2 |
|        39 | Christiansen |               4 |
|        14 | Sawayn       |               3 |
|        43 | Schulist     |               2 |
|        49 | Ankunding    |               2 |
|        22 | Considine    |               2 |
|        19 | Marks        |               2 |
|        29 | Kessler      |               2 |
|        44 | Wunsch       |               1 |
|        23 | Hodkiewicz   |               2 |
|         5 | Cremin       |               1 |
|         7 | Streich      |               1 |
|        17 | Berge        |               2 |
|        12 | Haag         |               2 |
|        16 | Kunde        |               4 |
|        40 | Goodwin      |               1 |
|        37 | Bradtke      |               2 |
|         8 | Hudson       |               3 |
|        42 | Gislason     |               2 |
|        32 | Dickens      |               1 |
|        34 | Kuvalis      |               2 |
|         4 | Rice         |               1 |
|        18 | Kiehn        |               1 |
|        47 | Stroman      |               3 |
|        36 | Kemmer       |               1 |
|        48 | Shanahan     |               2 |
|         3 | Schultz      |               1 |
|         9 | Moen         |               4 |
|        27 | Swift        |               1 |
|        21 | Sanford      |               1 |
|         6 | Weimann      |               1 |
|        11 | Crooks       |               1 |
|        33 | Stokes       |               1 |
|        46 | Mosciski     |               2 |
|        38 | Moen         |               1 |
|        24 | Kuhn         |               1 |
|        30 | Yost         |               1 |
|        13 | McDermott    |               1 |
|        10 | Fisher       |               1 |
+-----------+--------------+-----------------+
40 rows in set (0.00 sec)

'представление инциденты по клиентам'
mysql> select * from accidents_byclient;
+----------------+--------------+
| name           | client       |
+----------------+--------------+
| sed            | ipsum        |
| nobis          | impedit      |
| earum          | impedit      |
| NULL           | pariatur     |
| animi          | soluta       |
| earum          | soluta       |
| aperiam        | dignissimos  |
| voluptatem     | dignissimos  |
| saepe          | enim         |
| placeat        | enim         |
| est            | enim         |
| odit           | voluptas     |
| quae           | voluptas     |
| provident      | iusto        |
| rerum          | omnis        |
| cum            | tempora      |
| consequatur    | tempora      |
| NULL           | impedit      |
| tempore        | rerum        |
| incidunt       | rerum        |
| quo            | rerum        |
| non            | rerum        |
| voluptatem     | repellat     |
| quis           | repellat     |
| unde           | nobis        |
| beatae         | nobis        |
| qui            | nobis        |
| et             | consectetur  |
| quia           | consectetur  |
| quidem         | consectetur  |
| aliquam        | quas         |
| iure           | quas         |
| quam           | ex           |
| consequatur    | ex           |
| et             | adipisci     |
| veniam         | adipisci     |
| omnis          | adipisci     |
| dolor          | adipisci     |
| aut            | repellendus  |
| consectetur    | repellendus  |
| quia           | repellendus  |
| perspiciatis   | non          |
| enim           | earum        |
| quibusdam      | earum        |
| doloribus      | earum        |
| NULL           | provident    |
| dolorum        | corporis     |
| ut             | corporis     |
| aperiam        | corporis     |
| molestias      | corporis     |
| qui            | distinctio   |
| ea             | qui          |
| enim           | est          |
| sit            | sed          |
| ut             | sed          |
| explicabo      | sed          |
| ipsam          | consequatur  |
| inventore      | dolorem      |
| vel            | dolorem      |
| unde           | debitis      |
| iste           | debitis      |
| magnam         | totam        |
| accusamus      | quasi        |
| sunt           | quasi        |
| dolorem        | quasi        |
| vitae          | laudantium   |
| voluptatem     | laudantium   |
| vitae          | laudantium   |
| repellendus    | laudantium   |
| NULL           | magnam       |
| similique      | ea           |
| incidunt       | iure         |
| sunt           | iure         |
| NULL           | sint         |
| NULL           | dolorem      |
| et             | quaerat      |
| nostrum        | quaerat      |
| occaecati      | quaerat      |
| atque          | culpa        |
| inventore      | culpa        |
| blanditiis     | culpa        |
| itaque         | voluptatum   |
| rerum          | voluptatum   |
| ut             | voluptatum   |
| voluptate      | voluptatum   |
| quo            | aut          |
| voluptas       | velit        |
| et             | nostrum      |
| omnis          | nostrum      |
| adipisci       | nostrum      |
| NULL           | modi         |
| exercitationem | temporibus   |
| iste           | temporibus   |
| vel            | corporis     |
| modi           | corporis     |
| quod           | corporis     |
| et             | corporis     |
| et             | corporis     |
| NULL           | commodi      |
| error          | similique    |
| illo           | similique    |
| dolorem        | similique    |
| amet           | esse         |
| debitis        | esse         |
| ut             | esse         |
| sit            | quibusdam    |
| eos            | quibusdam    |
| hic            | quibusdam    |
| NULL           | ut           |
| eaque          | suscipit     |
| voluptatibus   | molestias    |
| voluptate      | at           |
| similique      | at           |
| tenetur        | molestias    |
| natus          | molestias    |
| adipisci       | molestias    |
| NULL           | voluptatum   |
| NULL           | sunt         |
| perferendis    | sint         |
| quia           | sint         |
| asperiores     | sit          |
| ducimus        | sit          |
| rem            | sit          |
| quasi          | repellat     |
| itaque         | repellat     |
| repellat       | repellat     |
| NULL           | dolor        |
| et             | quis         |
| voluptatem     | quis         |
| dolore         | quis         |
| et             | quis         |
| qui            | quis         |
| deserunt       | est          |
| ea             | est          |
| nesciunt       | nesciunt     |
| voluptatem     | nesciunt     |
| fugiat         | nesciunt     |
| sit            | nesciunt     |
| sed            | consequatur  |
| repudiandae    | occaecati    |
| totam          | est          |
| et             | est          |
| dicta          | perferendis  |
| est            | voluptas     |
| similique      | voluptas     |
| earum          | sed          |
| recusandae     | laborum      |
| quisquam       | id           |
| voluptates     | id           |
| ipsam          | id           |
| cum            | id           |
| quia           | id           |
| eos            | repudiandae  |
| non            | repudiandae  |
| quis           | repudiandae  |
| ut             | repudiandae  |
| aut            | voluptatem   |
| quasi          | vitae        |
| necessitatibus | unde         |
| error          | unde         |
| ipsum          | unde         |
| ut             | blanditiis   |
| ipsum          | blanditiis   |
| sint           | blanditiis   |
| quia           | neque        |
| eum            | neque        |
| minima         | neque        |
| voluptas       | neque        |
| et             | neque        |
| voluptatem     | consectetur  |
| rerum          | consectetur  |
| reprehenderit  | consectetur  |
| neque          | earum        |
| vitae          | earum        |
| autem          | earum        |
| voluptatibus   | earum        |
| debitis        | molestias    |
| impedit        | molestias    |
| nobis          | quam         |
| beatae         | quam         |
| NULL           | rem          |
| sunt           | sit          |
| et             | sit          |
| vitae          | sit          |
| voluptatem     | sit          |
| NULL           | quaerat      |
| nulla          | iure         |
| et             | iure         |
| qui            | iure         |
| sapiente       | dolor        |
| explicabo      | dolor        |
| rerum          | aliquid      |
| dolorum        | aliquid      |
| inventore      | aliquid      |
| qui            | aliquid      |
| alias          | rerum        |
| excepturi      | rerum        |
| blanditiis     | totam        |
| quidem         | totam        |
| qui            | totam        |
| aut            | consectetur  |
| quae           | quia         |
| inventore      | quia         |
| deleniti       | voluptatibus |
| NULL           | libero       |
| NULL           | recusandae   |
| in             | fugit        |
| est            | fugit        |
| unde           | et           |
| sit            | et           |
| deleniti       | et           |
| magnam         | et           |
| et             | et           |
| dicta          | est          |
| et             | est          |
| corporis       | omnis        |
+----------------+--------------+
216 rows in set (0.00 sec)

'представление наименования инцидентов по владельцам'
mysql> select * from accidents_byowner;
+----------------+---------------------------------------------------------+
| name           | owner                                                   |
+----------------+---------------------------------------------------------+
| molestias      | Владелец неопределен                                    |
| occaecati      | Владелец неопределен                                    |
| earum          | Владелец неопределен                                    |
| perspiciatis   | Владелец неопределен                                    |
| et             | Владелец неопределен                                    |
| quis           | Владелец неопределен                                    |
| ut             | Владелец неопределен                                    |
| consectetur    | Владелец неопределен                                    |
| ut             | Владелец неопределен                                    |
| quia           | Владелец неопределен                                    |
| ea             | Владелец неопределен                                    |
| dolorem        | Владелец неопределен                                    |
| inventore      | Владелец неопределен                                    |
| quibusdam      | Владелец неопределен                                    |
| voluptas       | Владелец неопределен                                    |
| dicta          | Владелец неопределен                                    |
| rerum          | Владелец неопределен                                    |
| eos            | Владелец неопределен                                    |
| debitis        | Владелец неопределен                                    |
| fugiat         | Владелец неопределен                                    |
| inventore      | Владелец неопределен                                    |
| voluptatem     | Владелец неопределен                                    |
| voluptas       | Владелец неопределен                                    |
| tenetur        | Владелец неопределен                                    |
| voluptate      | Владелец неопределен                                    |
| sunt           | Владелец неопределен                                    |
| atque          | Владелец неопределен                                    |
| sit            | Владелец неопределен                                    |
| est            | Владелец неопределен                                    |
| qui            | Авиационное производство                                |
| iste           | Авиационное производство                                |
| provident      | Авиационное производство                                |
| vitae          | Авиационное производство                                |
| explicabo      | Авиационное производство                                |
| et             | Авиационное производство                                |
| natus          | Авиационное производство                                |
| sit            | Авиационное производство                                |
| ut             | Авиационное производство                                |
| asperiores     | Авиационное производство                                |
| incidunt       | Авиационное производство                                |
| nostrum        | Авиационное производство                                |
| et             | Авиационное производство                                |
| nesciunt       | Авиационное производство                                |
| unde           | Авиационное производство                                |
| beatae         | Делопроизводство                                        |
| qui            | Делопроизводство                                        |
| voluptatibus   | Делопроизводство                                        |
| aliquam        | Делопроизводство                                        |
| ipsam          | Делопроизводство                                        |
| hic            | Делопроизводство                                        |
| sed            | Делопроизводство                                        |
| aperiam        | Делопроизводство                                        |
| voluptates     | Делопроизводство                                        |
| unde           | Делопроизводство                                        |
| non            | Делопроизводство                                        |
| error          | Делопроизводство                                        |
| vitae          | Делопроизводство                                        |
| ut             | Делопроизводство                                        |
| deleniti       | Делопроизводство                                        |
| incidunt       | Делопроизводство                                        |
| quia           | Делопроизводство                                        |
| vel            | Информационные технологии                               |
| similique      | Информационные технологии                               |
| voluptatibus   | Информационные технологии                               |
| est            | Информационные технологии                               |
| enim           | Информационные технологии                               |
| voluptate      | Информационные технологии                               |
| repudiandae    | Информационные технологии                               |
| et             | Информационные технологии                               |
| inventore      | Информационные технологии                               |
| magnam         | Информационные технологии                               |
| quod           | Информационные технологии                               |
| voluptatem     | Информационные технологии                               |
| rerum          | Информационные технологии                               |
| illo           | Информационные технологии                               |
| enim           | Информационные технологии                               |
| unde           | Информационные технологии                               |
| eum            | Информационные технологии                               |
| voluptatem     | Информационные технологии                               |
| necessitatibus | Информационные технологии                               |
| sit            | Информационные технологии                               |
| in             | Информационные технологии                               |
| nulla          | Информационные технологии                               |
| et             | Сопутствующее производство                              |
| adipisci       | Сопутствующее производство                              |
| qui            | Сопутствующее производство                              |
| aut            | Сопутствующее производство                              |
| consequatur    | Сопутствующее производство                              |
| iste           | Сопутствующее производство                              |
| quidem         | Сопутствующее производство                              |
| quis           | Сопутствующее производство                              |
| quidem         | Сопутствующее производство                              |
| et             | Сопутствующее производство                              |
| ducimus        | Сопутствующее производство                              |
| itaque         | Сопутствующее производство                              |
| quisquam       | Сопутствующее производство                              |
| aperiam        | Сопутствующее производство                              |
| nobis          | Сопутствующее производство                              |
| alias          | Сопутствующее производство                              |
| ipsam          | Сопутствующее производство                              |
| ea             | Сопутствующее производство                              |
| quae           | Сопутствующее производство                              |
| aut            | Вспомогательное производство                            |
| sunt           | Вспомогательное производство                            |
| dolor          | Вспомогательное производство                            |
| quo            | Вспомогательное производство                            |
| omnis          | Вспомогательное производство                            |
| error          | Вспомогательное производство                            |
| sed            | Вспомогательное производство                            |
| vitae          | Вспомогательное производство                            |
| inventore      | Вспомогательное производство                            |
| impedit        | Вспомогательное производство                            |
| voluptatem     | Вспомогательное производство                            |
| exercitationem | Вспомогательное производство                            |
| quasi          | Вспомогательное производство                            |
| deserunt       | Вспомогательное производство                            |
| rerum          | Вспомогательное производство                            |
| repellendus    | Маркетинг                                               |
| et             | Маркетинг                                               |
| placeat        | Маркетинг                                               |
| qui            | Маркетинг                                               |
| quia           | Маркетинг                                               |
| adipisci       | Маркетинг                                               |
| omnis          | Маркетинг                                               |
| et             | Маркетинг                                               |
| cum            | Маркетинг                                               |
| explicabo      | Маркетинг                                               |
| iure           | Маркетинг                                               |
| dolorum        | Маркетинг                                               |
| itaque         | Маркетинг                                               |
| deleniti       | Маркетинг                                               |
| similique      | Маркетинг                                               |
| earum          | Маркетинг                                               |
| consequatur    | Маркетинг                                               |
| accusamus      | Маркетинг                                               |
| dolorum        | Маркетинг                                               |
| quia           | Персонал                                                |
| sit            | Персонал                                                |
| repellat       | Персонал                                                |
| ipsum          | Персонал                                                |
| dolorem        | Персонал                                                |
| reprehenderit  | Персонал                                                |
| perferendis    | Персонал                                                |
| minima         | Персонал                                                |
| recusandae     | Персонал                                                |
| similique      | Персонал                                                |
| sunt           | Персонал                                                |
| aut            | Персонал                                                |
| blanditiis     | Финансы                                                 |
| qui            | Финансы                                                 |
| qui            | Финансы                                                 |
| excepturi      | Финансы                                                 |
| non            | Финансы                                                 |
| sint           | Финансы                                                 |
| sapiente       | Финансы                                                 |
| autem          | Финансы                                                 |
| quia           | Финансы                                                 |
| totam          | Финансы                                                 |
| ut             | Финансы                                                 |
| veniam         | Финансы                                                 |
| et             | Финансы                                                 |
| et             | Финансы                                                 |
| modi           | Финансы                                                 |
| et             | Финансы                                                 |
| neque          | Финансы                                                 |
| corporis       | Финансы                                                 |
| dicta          | Финансы                                                 |
| vitae          | Финансы                                                 |
| et             | Финансы                                                 |
| et             | Финансы                                                 |
| quo            | Финансы                                                 |
| tempore        | Финансы                                                 |
| odit           | Финансы                                                 |
| et             | Финансы                                                 |
| rem            | Безопасность                                            |
| voluptatem     | Безопасность                                            |
| doloribus      | Безопасность                                            |
| ut             | Безопасность                                            |
| ipsum          | Безопасность                                            |
| blanditiis     | Безопасность                                            |
| beatae         | Безопасность                                            |
| quae           | Безопасность                                            |
| eaque          | Безопасность                                            |
| voluptatem     | Безопасность                                            |
| debitis        | Безопасность                                            |
| amet           | Безопасность                                            |
| dolore         | Безопасность                                            |
| est            | Безопасность                                            |
| nobis          | Безопасность                                            |
| quasi          | Безопасность                                            |
| vel            | Безопасность                                            |
| rerum          | Безопасность                                            |
| saepe          | Безопасность                                            |
| cum            | Безопасность                                            |
| voluptatem     | Безопасность                                            |
| magnam         | Безопасность                                            |
| eos            | Безопасность                                            |
| earum          | Безопасность                                            |
| quam           | Безопасность                                            |
| animi          | Безопасность                                            |
| NULL           | Правовое обеспечение                                    |
| NULL           | Управление                                              |
+----------------+---------------------------------------------------------+
202 rows in set (0.00 sec)
