Proyecto Retail Sales

Este proyecto contiene consultas SQL para limpieza de datos, exploración y análisis de ventas.

📊 Exploración inicial

-- Mostrar primeras 10 filas
SELECT *
FROM retail_sales
LIMIT 10;

🧹 Limpieza de datos

Verificar valores nulos

SELECT
    SUM(CASE WHEN transactions_id IS NULL THEN 1 ELSE 0 END) AS transactions_id_NULL,
    SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS sale_date_NULL,
    SUM(CASE WHEN sale_time IS NULL THEN 1 ELSE 0 END) AS sale_time_NULL,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_NULL,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_NULL,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_NULL,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_NULL,
    SUM(CASE WHEN quantiy IS NULL THEN 1 ELSE 0 END) AS quantiy_NULL,
    SUM(CASE WHEN price_per_unit IS NULL THEN 1 ELSE 0 END) AS price_per_unit_NULL,
    SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS cogs_NULL,
    SUM(CASE WHEN total_sale IS NULL THEN 1 ELSE 0 END) AS total_sale_NULL
FROM retail_sales;

Eliminar filas con valores nulos

DELETE FROM retail_sales
WHERE cogs IS NULL;

DELETE FROM retail_sales
WHERE age IS NULL;

🔎 Exploración de datos

Número de ventas

SELECT COUNT(transactions_id) AS total_transactions FROM retail_sales;

Clientes únicos

SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

Edad promedio, mínima y máxima

SELECT AVG(age) AS average_age,
       MIN(age) AS min_age,
       MAX(age) AS max_age
FROM retail_sales;

Categorías únicas

SELECT DISTINCT category
FROM retail_sales;

📈 Análisis de negocio

Q1: Ventas del 2022-11-05

SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';

Q2: Transacciones de ropa con cantidad >= 4 en Nov-2022

SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

Q3: Total de ventas y precio promedio por categoría

SELECT category,
       SUM(total_sale) AS category_total_sales,
       AVG(price_per_unit) AS average_price
FROM retail_sales
GROUP BY category
ORDER BY category_total_sales DESC;

Q4: Edad promedio de clientes en categoría 'Beauty'

WITH t1 AS (
    SELECT *
    FROM retail_sales
    WHERE category = 'Beauty'
)
SELECT ROUND(AVG(age), 2) AS average_age_beauty
FROM t1;

Q5: Transacciones con total_sale > 1000

SELECT *
FROM retail_sales
WHERE total_sale > 1000
ORDER BY total_sale DESC;

Q6: Número de transacciones por género y categoría

SELECT gender,
       category,
       COUNT(transactions_id) AS sale_by_gender
FROM retail_sales
GROUP BY gender, category
ORDER BY gender, sale_by_gender DESC;

Q7: Mejor mes de ventas por año

WITH t1 AS (
    SELECT EXTRACT(YEAR FROM sale_date) AS year,
           EXTRACT(MONTH FROM sale_date) AS month,
           AVG(total_sale) AS avg_month_sale,
           RANK() OVER (
               PARTITION BY EXTRACT(YEAR FROM sale_date)
               ORDER BY AVG(total_sale) DESC
           ) AS rank
    FROM retail_sales
    GROUP BY year, month
)
SELECT year, month, avg_month_sale
FROM t1
WHERE rank = 1;

Q8: Top 5 clientes por ventas

SELECT customer_id,
       SUM(total_sale) AS total_sales,
       RANK() OVER (ORDER BY SUM(total_sale) DESC) AS top_customers
FROM retail_sales
GROUP BY customer_id
LIMIT 5;

Q9: Número de clientes únicos por categoría

SELECT category,
       COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;

Q10: Turnos y número de órdenes

WITH t1 AS (
    SELECT *,
           CASE
               WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
               WHEN EXTRACT(HOUR FROM sale_time) > 12 AND EXTRACT(HOUR FROM sale_time) <= 17 THEN 'Afternoon'
               ELSE 'Evening'
           END AS shifts
    FROM retail_sales
)
SELECT shifts, COUNT(*) AS shift_orders
FROM t1
GROUP BY shifts;

✅ Fin del proyecto
