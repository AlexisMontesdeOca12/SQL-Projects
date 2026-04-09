# For the region with the largest (sum)
of sales total_amt_usd, how many total (count)
orders were placed?

SELECT t1.region_name, t2.total_orders
FROM
  (SELECT r.name region_name, sum(o.total_amt_usd) total
  FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
  JOIN accounts a
  ON s.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
  group by region_name) t1
JOIN
  (SELECT r.name region_name, count(o.id) total_orders
  FROM orders o
  JOIN accounts a
  ON o.account_id = a.id
  JOIN sales_reps s
  ON a.sales_rep_id = s.id
  JOIN region r
  ON s.region_id = r.id
  GROUP BY 1) t2
ON t1.region_name = t2.region_name
ORDER BY 2 DESC
limit 1


¿Cuántas cuentas han realizado más compras en total que la cuenta que ha comprado la mayor cantidad de papel «standard_qty» a lo largo de su trayectoria como cliente?

# Filtros como WHERE o HAVING no requieren de nombre de tabla

SELECT count(account_name)
FROM
(SELECT a.name account_name
FROM accounts a
JOIN orders o
ON o.account_id = a.id
group BY 1
HAVING sum(o.total) > (SELECT total
FROM
  (SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1) t1)) t2


For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

SELECT t2.account_name, t1.channel, count(*) events
FROM
  (SELECT w.id, a.name account_name, w.channel
  FROM web_events w
  JOIN accounts a
  on w.account_id = a.id
  GROUP BY 1, 2, 3
  ORDER BY 2) t1
JOIN
  (SELECT a.name account_name, sum(total_amt_usd) total_spend
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1) t2
ON t1.account_name = t2.account_name
GROUP BY 1, 2
ORDER BY 3 DESC


What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

SELECT avg(total_spend) average
FROM
(SELECT a.name account_name, SUM(total_amt_usd) total_spend
FROM accounts a
JOIN  orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)



What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

SELECT avg(avg_amt)
FROM
  (SELECT a.name account_name, AVG(o.total_amt_usd) avg_amt
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  HAVING avg(o.total_amt_usd) > (SELECT avg(o.total_amt_usd) average_spend
  FROM orders o)) t1

# WITH - Common table events

You need to find the average number of events for each channel per day.


SELECT channel, avg(events)
FROM
  (SELECT DATE_TRUNC('day', occurred_at) AS day, channel, count(*) events
  FROM web_events
  GROUP BY 1, 2)
GROUP BY 1
ORDER by 2 DESC


# Utilizando WITH


WITH events AS (
  SELECT DATE_TRUNC('day',occurred_at) AS day,
  channel, COUNT(*) as events
  FROM web_events
  GROUP BY 1,2)

SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;


# JOIN de tablas con WITH

WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;



Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.


WITH t1 AS (
  SELECT s.name AS reps, r.name AS region_name, SUM(o.total_amt_usd) total_spend
  FROM sales_reps s
  JOIN region r
  ON s.region_id = r.id
  JOIN accounts a
  on s.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1, 2),


t2 AS (
  SELECT region_name, max(total_spend) total_spend
  FROM t1
  GROUP BY 1)


SELECT t1.reps, t1.region_name, t2.total_spend
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_spend = t2.total_spend



For the region with the largest sales total_amt_usd, how many total orders were placed?

WITH t1 AS (SELECT r.name region_name, SUM(o.total_amt_usd) total_spend
FROM region r
JOIN sales_reps s
on s.region_id = r.id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
on a.id = o.account_id
GROUP BY 1),

t2 as (
  SELECT max(total_spend)
  FROM t1
)

SELECT r.name region_name, COUNT(o.total) total_orders
FROM region r
JOIN sales_reps s
on s.region_id = r.id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
on a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2)


How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

WITH t1 AS (
      SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
      FROM accounts a
      JOIN orders o
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1),
t2 AS (
      SELECT a.name
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY 1
      HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;


For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

WITH t1 AS (
      SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
      LIMIT 1)

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;


What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

WITH t1 AS
(SELECT a.name account_name, sum(o.total_amt_usd) total_spend
FROM accounts a
JOIN orders o
on a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)

SELECT AVG(total_spend)
FROM t1


¿Cuál es el gasto medio a lo largo de la vida del cliente en términos de total_amt_usd, teniendo en cuenta únicamente a las empresas que, de media, gastaron más por pedido que la media de todos los pedidos?

WITH t1 AS (
  SELECT a.name AS account_name, AVG(o.total_amt_usd) AS avg_amt
  FROM orders o
  JOIN accounts a ON a.id = o.account_id
  GROUP BY a.name
),
t2 AS (
  SELECT AVG(o.total_amt_usd) AS total_spend
  FROM orders o
)
SELECT AVG(t1.avg_amt) AS avg_accounts
FROM t1
WHERE t1.avg_amt > (SELECT total_spend FROM t2);


# LEFT, RIGHT, LENGTH

In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here(opens in a new tab). Pull these extensions and provide how many of each website type exist in the accounts table.

WITH t1 AS
(SELECT RIGHT(website, 3) AS extensions
FROM accounts
)

SELECT t1.extensions, COUNT(*)
FROM t1
GROUP BY 1

There is much debate about how much the name (or even the first letter of a company name)(opens in a new tab) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).

WITH t1 as
(SELECT LEFT(name, 1) account_name, COUNT(*) letters
FROM accounts
GROUP BY 1
ORDER BY 2)

SELECT SUM(letters)
FROM t1



Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter?

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                          THEN 1 ELSE 0 END AS num,
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;


Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?

SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                           THEN 1 ELSE 0 END AS vowels,
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;


# POSITION & STRPOS
Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.

SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first_name, RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name
FROM accounts


Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.

SELECT name, LEFT(name, POSITION(' ' in name) -1) as first_name, RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) AS last_name
FROM sales_reps


# CONCAT
CONCAT(first_name, ' ', last_name)


Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first_name of the primary_poc.last_name@company_name.com

WITH t1 AS
(SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) -1) as first_name, RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' in primary_poc)) AS last_name, name
FROM accounts)

SELECT lower(CONCAT(first_name, '.', last_name, '@', name, '.com'))
FROM t1


You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your solution should be just as in question 1. Some helpful documentation is here(opens in a new tab).

# Sintaxis
REPLACE(name, ' ', '') AS nombre_sin_espacios
REPLACE(row, 'texto_a_buscar','texto_de_reemplazo')

WITH t1 AS
(SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) -1) as first_name, RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' in primary_poc)) AS last_name, REPLACE(name, ' ', '') AS company_name
FROM accounts)

SELECT lower(CONCAT(first_name, '.', last_name, '@', company_name, '.com'))
FROM t1



We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc first name (lowercase),

then the last letter of their first name (lowercase),

the first letter of their last name (lowercase),

the last letter of their last name (lowercase),

the number of letters in their first name,

the number of letters in their last name,

and then the name of the company they are working with, all capitalized with no spaces.



WITH t1 AS
(SELECT LEFT(primary_poc, 1) AS first_letter_first, RIGHT(LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1), 1) AS last_letter_first, LEFT(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)), 1) AS first_letter_last, RIGHT(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)), 1) AS last_letter_last, LENGTH(LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)) AS LENGTH_first, LENGTH(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc))) as LENGTH_last, REPLACE(name, ' ', '') AS company_name
FROM accounts)


SELECT lower(CONCAT(first_letter_first, last_letter_first, first_letter_last, last_letter_last, LENGTH_first, LENGTH_last, company_name))
FROM t1



# Covertir meses a numero de meses

DATE_PART('month', TO_DATE(month, 'month'))

# Convierte columnas en otro tipo de datos
CAST(date_column AS DATE),

01/31/2014
# FORMATO SQL: 2014/01/31

# Sintaxis SUBSTR(cadena, inicio, longitud)

SELECT CAST(CONCAT(SUBSTR(DATE, 7, 4), '/', SUBSTR(DATE, 1, 2), '/', SUBSTR(DATE, 4, 2)) as DATE ) AS date_fix
FROM sf_crime_data
LIMIT 10


# Reemplazar valores nulos (null) por alguna constante





# Window Function

SELECT column1,
      window_function(column2)
      OVER ([PARTITION BY column3] [ORDER BY column4]) AS alias_name
FROM table_name;

# Sintaxis:
window_function: e.g., SUM(), AVG(), ROW_NUMBER(), RANK(), LAG().

PARTITION BY: Divides rows into groups (optional).

ORDER BY: Defines row order within each partition (optional).

"""Using Derek's previous video as an example, create another running total. This time, create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. Your final table should have two columns: one with the amount being added for each new row, and a second with the running total."""


SELECT standard_amt_usd, sum(standard_amt_usd) OVER(ORDER BY occurred_at) as standard_acumulated, occurred_at
FROM orders



"""Now, modify your query from the previous quiz to include partitions. Still create a running total of standard_amt_usd (in the orders table) over order time, but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable. Your final table should have three columns: One with the amount being added for each row, one for the truncated date, and a final column with the running total within each year."""


SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) as year,
       SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders
