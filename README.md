# Orders Sales Analysis

## Table of Contents
- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Recommedations](#recommedations)
- [Results and Findings](#results-and-findings)
- [Limitations](#limitations)
- [References](#references)

  ---

### Project Overview
This orders analysis project aims to provide insights into orders made in a retail outlet for the year 2022 and year 2023 comparing sales and profit for different region and much more. by analyzing various aspects of orders data we seek to indentify trends, make data driven recommedations and gain a deeper understand of the orders performance in the retail outlet.

#### Month Profit Comparision Growth
![month_profit_comparision_growth_%](https://github.com/Joendege/Orders-Analysis-Report-Python-and-SQL-Server/assets/123901910/56137cd9-ba44-4155-a49e-3b7072679682)

#### Region Yearly Sales Growth
![region_yearly_sales_growth](https://github.com/Joendege/Orders-Analysis-Report-Python-and-SQL-Server/assets/123901910/6ba34065-6676-42b7-bf99-1ad66c81ab25)

#### Yearly Profit Growth by Subcategory
![year_profit_growth_by_subcategory](https://github.com/Joendege/Orders-Analysis-Report-Python-and-SQL-Server/assets/123901910/a780e78c-6de1-4b93-b0b2-924ce7087002)


### Data Sources
The primary data set used for this analaysis was from kaggle website where I used kaggle API to import the 'orders.csv' zip file and later loaded it to a dataframe for cleaning and analysis, the data contains each record of every orders record made to the outlet for two years.

### Tools
1. Python Pandas - Data loading using API, Data Cleaning, Importing to SQL Server DB [Download Here](https://jupyter.org/install)
2. MS SQL Server - Data analysis and Reporting [Download Here](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

### Data Cleaning and Preparation
In the initial data cleaning phase we undertook the following tasks:
1. Data loading and Inspection
2. Handling missing values
3. Addition of new columns
4. Data formatting

### Exploratory Data Analysis
EDA involved exploring the orders data to answer key questions such as:
1. Which are the top ten high revenue generating products?
2. Which are the top five products in each region?
3. How is the sales comparison month by month over the two years and the growth percebtage?
4. How is the profit comparison month by nonth over the two years and the growth percentage?
5. Which is the top category by sales per month over the two years?
6. Foe each category, which month had the highest sales?
7. How is profit and sales comparison over the two years relation to each subcategory?
8. How is region sales growth

### Data Analysis
```SQL
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
```
```SQL
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
```
```SQL
-- Top category by sales per month over the two years
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
```
```SQL
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
```
```SQL
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
```
```SQL
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
```

### Recommedations
Based on the analysis, we recommed the following actions:
1. Increase promotions and markting for the furniture products.
2. More efforts in the months of June and August to increase sales revenue.
3. Focus on marketing and creating awareness for South and West region.

### Results and Findings
The analysis results are summarized as follows:
1. Central region is best in terms of sales revenue
2. Month of February had the highest growth in terms of sales revenue
3. Technology category is the best performing category in most of the months based on sales revenue.

### Limitations
I had to replace the values of "not available" and "unknown"  in the ship_mode column with null values.

### References
1. [Stack Overflow](https://stackoverflow.com/)
2. [W3 Schools](https://www.w3schools.com/)
3. [Pandas Documentation](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_csv.html)
