# Analisis Venta Minorista Projecto SQL


# Limpiza de datos
## Verificar valores nulos

'''SELECT
SUM(CASE WHEN transactions_id IS NULL THEN 1 ELSE 0 END) as transactions_id_NULL,
SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) as sale_date_NULL,
SUM(CASE WHEN sale_time IS NULL THEN 1 ELSE 0 END) as sale_time_NULL,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as customer_id_NULL,
SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) as gender_NULL,
SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) as age_NULL,
SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) as category_NULL,
SUM(CASE WHEN quantiy IS NULL THEN 1 ELSE 0 END) as quantiy_NULL,
SUM(CASE WHEN price_per_unit IS NULL THEN 1 ELSE 0 END) as price_per_unit_NULL,
SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) as cogs_NULL,
SUM(CASE WHEN total_sale IS NULL THEN 1 ELSE 0 END) as total_sale_NULL
FROM retail_sales'''
