--Top Ten high revenue generating products

SELECT TOP 10
	product_id,
	SUM(sale_price) total_revenue
FROM df_orders
GROUP BY product_id
ORDER BY total_revenue DESC

--Top 5 products in each region

SELECT 
	a.product_id,
	a.region,
	a.total_sales
FROM
		(SELECT 
			product_id,
			region,
			SUM(sale_price) total_sales,
			ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(sale_price) DESC) AS row_num
		FROM df_orders
		GROUP BY region, product_id) a
WHERE a.row_num < 6

--Month to month sales comparision for year 2022 and 2023

SELECT 
	b.*,
	CONCAT(CAST((b.sales_2023 - b.sales_2022) * 100 / b.sales_2022 AS DECIMAL(5, 2)), '%') percent_growth
FROM
	(SELECT 
		a.month_name,
		SUM(CASE WHEN a.order_year = 2022 THEN a.total_sales ELSE 0 END) AS sales_2022,
		SUM(CASE WHEN a.order_year = 2023 THEN a.total_sales ELSE 0 END) AS sales_2023
	FROM
		(SELECT 
			YEAR(order_date) order_year,
			MONTH(order_date) order_month,
			FORMAT(order_date, 'MMMM') month_name,
			SUM(sale_price) total_sales
		FROM df_orders
		GROUP BY YEAR(order_date), MONTH(order_date), FORMAT(order_date, 'MMMM')) a
	GROUP BY a.month_name, a.order_month) b


--month to month profit comparision for year 2022 and 2023 and growth percentage

SELECT 
	b.*,
	CAST((b.profit_2023 - b.profit_2022) * 100 / b.profit_2022 AS DECIMAL(10,2)) AS profit_growth
FROM
	(SELECT 
		a.month_name,
		SUM(CASE WHEN a.order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
		SUM(CASE WHEN a.order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
	FROM
		(SELECT 
			YEAR(order_date) order_year,
			MONTH(order_date) order_month,
			FORMAT(order_date, 'MMM') month_name,
			SUM(profit) total_profit
		FROM df_orders
		GROUP BY YEAR(order_date), MONTH(order_date), FORMAT(order_date, 'MMM')) a
	GROUP BY a.month_name, a.order_month) b 


-- Top category by sales per month over the two years
SELECT 
	a.category,
	a.order_year,
	a.month_name,
	a.total_sales
FROM 
	(SELECT 
		category,
		YEAR(order_date) order_year,
		MONTH(order_date) order_month,
		FORMAT(order_date, 'MMMM') month_name,
		SUM(sale_price) total_sales,
		ROW_NUMBER() OVER(PARTITION BY YEAR(order_date), MONTH(order_date), FORMAT(order_date, 'MMMM') ORDER BY MONTH(order_date) ASC, SUM(sale_price) DESC) AS row_num
	FROM df_orders
	GROUP BY category, YEAR(order_date), MONTH(order_date), FORMAT(order_date, 'MMMM')) a
WHERE a.row_num = 1

SELECT 
	a.category,
	a.order_yr_month,
	a.total_sales
FROM
	(SELECT 
		category,
		FORMAT(order_date, 'yyyy-MM') order_yr_month,
		SUM(sale_price) total_sales,
		ROW_NUMBER() OVER(PARTITION BY FORMAT(order_date, 'yyyy-MM') ORDER BY SUM(sale_price) DESC) AS row_num
	FROM df_orders
	GROUP BY category, FORMAT(order_date, 'yyyy-MM')) a
WHERE a.row_num = 1

--for each category which month had highest sales

SELECT 
	a.category,
	a.order_yr_month,
	a.total_sales
FROM
	(SELECT 
		category, 
		FORMAT(order_date, 'yyyy MMMM') order_yr_month,
		SUM(sale_price) total_sales,
		ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) AS row_num
	FROM df_orders
	GROUP BY category, FORMAT(order_date, 'yyyy MMMM')) a
WHERE a.row_num = 1


--Year 2022 and 2023 profit growth by subcategory

SELECT 
	b.*,
	CAST(((b.profit_23 - b.profit_22) * 100)/ b.profit_22 AS DECIMAL(10,2)) percent_growth
FROM
		(SELECT 
			a.sub_category,
			SUM(CASE WHEN a.order_year = 2022 THEN a.total_profit ELSE 0 END) AS profit_22,
			SUM(CASE WHEN a.order_year = 2023 THEN a.total_profit ELSE 0 END) AS profit_23
		FROM
			(SELECT 
				sub_category,
				YEAR(order_date) order_year,
				SUM(profit) total_profit
			FROM df_orders
			GROUP BY sub_category, YEAR(order_date)) a
		GROUP BY a.sub_category) b
ORDER BY percent_growth DESC


--Year percentage region growth of sales
SELECT 
	b.*,
	CONCAT(CAST((b.sales_2023 - b.sales_2022) * 100 / b.sales_2022 AS DECIMAL(5,2)), '%') sales_growth
FROM
	(SELECT 
		a.region,
		SUM(CASE WHEN a.order_year = 2022 THEN a.total_sales ELSE 0 END) AS sales_2022,
		SUM(CASE WHEN a.order_year = 2023 THEN a.total_sales ELSE 0 END) AS sales_2023
	FROM 
		(SELECT 
			region,
			YEAR(order_date) order_year,
			SUM(sale_price) total_sales
		FROM df_orders
		GROUP BY region, YEAR(order_date)) a
	GROUP BY a.region) b





