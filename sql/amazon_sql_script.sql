create database Amazon_database;
use Amazon_database;
select count(*) from clean_data;
select count(*) from returns_data;

-- Revenue & Transactions by Year
select year(date)as year,
 ROUND(SUM(Revenue), 2) as total_revenue,
sum(transaction_count) as total_transaction
from clean_data
group by year(date)
order by year;

-- Top 5 Departments by Revenue
select departments, ROUND(SUM(Revenue), 2)  as total_revenue
from clean_data
group by departments
order by total_revenue desc
limit 5;


-- Year-over-Year Revenue Growth
WITH rev AS (
    SELECT 
        YEAR(date) AS year,
        ROUND(SUM(Revenue), 2) AS total_revenue
    FROM clean_data
    GROUP BY YEAR(date)
)

SELECT 
    year,
    total_revenue,
    
    concat(ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY year)) 
        / LAG(total_revenue) OVER (ORDER BY year) * 100,
    2),'%') AS yoy_growth_percent

FROM rev;




--  Buyer Engagement Segment Performance
SELECT
    Buyer_Category,
    ROUND(SUM(Revenue), 2)          AS Total_Revenue,
    ROUND(AVG(Revenue), 2)          AS Avg_Revenue,
    SUM(Transaction_Count)          AS Total_Transactions
FROM clean_data
GROUP BY Buyer_Category
ORDER BY Total_Revenue DESC;



-- Buyer Segment YoY Growth
WITH rev AS (
    SELECT 
        Buyer_Category,
        YEAR(date) AS year,
        ROUND(SUM(Revenue), 2) AS total_revenue
    FROM clean_data
    GROUP BY Buyer_Category, YEAR(date)
)

SELECT 
    Buyer_Category,
    year,
    total_revenue,

    ROUND(
        (total_revenue - LAG(total_revenue) OVER (
            PARTITION BY Buyer_Category 
            ORDER BY year
        ))
        / LAG(total_revenue) OVER (
            PARTITION BY Buyer_Category 
            ORDER BY year
        ) * 100,
    2) AS yoy_growth_percent

FROM rev
ORDER BY Buyer_Category, year;



-- Department Segment YoY Growth
SELECT
    Buyer_Category,
    ROUND(SUM(Revenue), 2)          AS Total_Revenue,
    ROUND(AVG(Revenue), 2)          AS Avg_Revenue,
    SUM(Transaction_Count)          AS Total_Transactions
FROM clean_data
GROUP BY Buyer_Category
ORDER BY Total_Revenue DESC;



-- Buyer Segment YoY Growth
WITH rev AS (
    SELECT 
        Departments,
        YEAR(date) AS year,
        ROUND(SUM(Revenue), 2) AS total_revenue
    FROM clean_data
    GROUP BY Departments, YEAR(date)
)

SELECT 
    Departments,
    year,
    total_revenue,

    ROUND(
        (total_revenue - LAG(total_revenue) OVER (
            PARTITION BY Departments
            ORDER BY year
        ))
        / LAG(total_revenue) OVER (
            PARTITION BY Departments 
            ORDER BY year
        ) * 100,
    2) AS yoy_growth_percent

FROM rev
ORDER BY year,Departments;


-- Revenue by Merchant Category per Year
SELECT 
    Merchant_Category,
    YEAR(date) AS year,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM clean_data
GROUP BY Merchant_Category, YEAR(date)
ORDER BY Merchant_Category, year;



-- Revenue by departments per Year
SELECT 
    Departments,
    YEAR(date) AS year,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM clean_data
GROUP BY Departments, YEAR(date)
ORDER BY Departments, year;



select * from returns_data;
-- Returns Summary by Year
select Year(date) as year,
       round(sum(abs(Volume)),2) as total_returned_volume,
       round(sum(Transaction_Count),2) as return_transactions,
       round(sum(Revenue),2) as Returns_Revenue_Impact
	from returns_data
    group by Year(date) 
    order by year;
    
    

-- Returns by Department
 select Year(date) as year,
	    Departments,
       round(sum(abs(Volume)),2) as returned_volume,
       round(sum(Transaction_Count),2) as returned_count,
       round(sum(Revenue),2) as Returns_Revenue_Impact
	from returns_data
    group by Year(date) ,Departments
    order by year; 
    
    
-- Returns by Merchant Category
select 
	   Merchant_Category,
       round(sum(abs(Volume)),2) as returned_volume,
       round(sum(Transaction_Count),2) as returned_count,
       round(sum(Revenue),2) as Returns_Revenue_Impact
	from returns_data
    group by Merchant_Category
    order by returned_volume desc; 
    
    



-- Total Returns by Year
    SELECT 
    YEAR(date) AS year,
    ROUND(SUM(Revenue), 2) AS total_return_revenue,
    round(sum(abs(Volume)),2) as returned_volume
FROM returns_data
GROUP BY YEAR(date)
ORDER BY year;




-- Net Revenue by Year (joining both tables)
 WITH sales AS (
    SELECT 
        YEAR(date) AS year,
        ROUND(SUM(Revenue), 2) AS sales_revenue
    FROM clean_data
    GROUP BY YEAR(date)
),

returns AS (
    SELECT 
        YEAR(date) AS year,
        abs(ROUND(SUM(Revenue), 2)) AS return_revenue
    FROM returns_data
    GROUP BY YEAR(date)
)

SELECT 
    s.year,
    s.sales_revenue,
    COALESCE(r.return_revenue, 0) AS return_revenue,

    ROUND(
        s.sales_revenue - COALESCE(r.return_revenue, 0),
    2) AS net_revenue

FROM sales s
LEFT JOIN returns r 
    ON s.year = r.year

ORDER BY s.year;




-- Net Revenue by Department & Year

WITH sales AS (
    SELECT 
        Departments,
        YEAR(date) AS year,
        ROUND(SUM(Revenue), 2) AS sales_revenue
    FROM clean_data
    GROUP BY Departments, YEAR(date)
),

returns AS (
    SELECT 
        Departments,
        YEAR(date) AS year,
        ROUND(SUM(Revenue), 2) AS return_revenue
    FROM returns_data
    GROUP BY Departments, YEAR(date)
)

SELECT 
    s.Departments,
    s.year,
    s.sales_revenue,
    COALESCE(r.return_revenue, 0) AS return_revenue,

    ROUND(
        s.sales_revenue - COALESCE(r.return_revenue, 0),
    2) AS net_revenue

FROM sales s
LEFT JOIN returns r
    ON s.Departments = r.Departments
    AND s.year = r.year

ORDER BY s.Departments, s.year;


    

