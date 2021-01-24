
--В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

mysql> DROP DATABASE IF EXISTS sample;
Query OK, 0 rows affected, 1 warning (0.06 sec)

mysql> CREATE DATABASE sample;
Query OK, 1 row affected (0.04 sec)

mysql> use sample;
Database changed
mysql> DROP TABLE IF EXISTS users;
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> CREATE TABLE users(
    -> id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -> name VARCHAR(45) NOT NULL,
    -> birthday_at DATE DEFAULT NULL,
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    -> updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -> );
Query OK, 0 rows affected, 1 warning (0.11 sec)

mysql> START TRANSACTION;
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
Query OK, 1 row affected (0.02 sec)
Records: 1  Duplicates: 0  Warnings: 0

mysql> COMMIT;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from users;
+----+------------------+-------------+---------------------+---------------------+
| id | name             | birthday_at | created_at          | updated_at          |
+----+------------------+-------------+---------------------+---------------------+
|  1 | Геннадий         | 1990-10-05  | 2021-01-17 20:43:14 | 2021-01-17 20:43:14 |
+----+------------------+-------------+---------------------+---------------------+
1 row in set (0.01 sec)

--Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.

mysql> CREATE VIEW prods_desc(prod_id, prod_name, cat_name) AS
    -> SELECT p.id AS prod_id, p.name, cat.name
    -> FROM products AS p
    -> LEFT JOIN catalogs AS cat 
    -> ON p.catalog_id = cat.id;
Query OK, 0 rows affected (0.05 sec)

mysql> select * from prods_desc;
+---------+-------------------------+-----------------------------------+
| prod_id | prod_name               | cat_name                          |
+---------+-------------------------+-----------------------------------+
|       1 | Intel Core i3-8100      | Процессоры                        |
|       2 | Intel Core i5-7400      | Процессоры                        |
|       3 | AMD FX-8320E            | Процессоры                        |
|       4 | AMD FX-8320             | Процессоры                        |
|       5 | ASUS ROG MAXIMUS X HERO | Материнские платы                 |
|       6 | Gigabyte H310M S2H      | Материнские платы                 |
|       7 | MSI B250M GAMING PRO    | Материнские платы                 |
+---------+-------------------------+-----------------------------------+
7 rows in set (0.01 sec)

--Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.

mysql> drop procedure if exists hello;
    -> delimiter//
Query OK, 0 rows affected (0.07 sec)

ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'delimiter' at line 1
mysql> create procedure hello()
    -> begin
    -> case
    -> when curtime() between '06:00:00' and '12:00:00' then 
    -> select 'Доброе утро';
    -> when curtime() between '12:00:00' and '18:00:00' then
    -> select 'Добрый день';
    -> when curtime() between '18:00:00' and '00:00:00' then
    -> select 'Добрый вечер';
    -> else select 'Доброй ночи';
    -> end case;
    -> end//
Query OK, 0 rows affected (0.03 sec)

mysql> call hello();
    -> //
+-----------------------+
| Добрый день           |
+-----------------------+

1 row in set (0.02 sec)

Query OK, 0 rows affected (0.02 sec)

--В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей или одно из них. 
mysql> create trigger nullTrigger before insert on products
    ->     for each row
    ->     begin
    ->     if(isnull(new.name) and isnull(new.desription)) then
    ->     
    ->     signal sqlstate'45000' set message_text = 'Незаполнены оба поля!';
    ->     end if;
    ->     end//
Query OK, 0 rows affected (0.03 sec)
--проверяем 
mysql> insert into products (name, desription, price, catalog_id)
    ->     values (NULL, NULL, 5000, 2); 
    -> //
ERROR 1644 (45000): Незаполнены оба поля!


