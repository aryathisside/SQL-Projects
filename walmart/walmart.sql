-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date TIMESTAMP NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2)
);

-----------------------------------------------------------------------------
------------------------Feature Engineering ---------------------------------

---time_of_day

SELECT 
    "time",
    CASE
        WHEN "time" BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN "time" BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;


alter table sales add column time_of_day varchar(20)

update sales
set time_of_day = (
    CASE
        WHEN "time" BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN "time" BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
)


select * from sales


--day_name

select 
	date,
	to_char(date,'Day') as day_name
from sales


alter table sales add column day_name varchar(20)

update sales
set day_name = to_char(date,'Day')


--month_name

select 
	date,
	to_char(date,'Mon')
from sales

alter table sales add column month_name varchar(10)

update sales
set month_name = to_char(date,'Mon')


-----------------------------------------------------------------------------
---------------------------Generic Question ---------------------------------

--Q1. How many unique cities does the data have?

select 	
	distinct city,
	count(distinct city)  as total_unqiue_cities
	
from sales
group by city

--Q2. In which city is each branch?

select 	
	distinct city,
	branch
from sales

-----------------------------------------------------------------------------
---------------------------Product Question ---------------------------------
select * from sales

--Q1.How many unique product lines does the data have?

select 
	distinct product_line
from sales

--Q2. What is the most common payment method?

select 
	payment,
	count(payment)
from sales
group by 1
order by 2 desc 

--Q3. What is the most selling product line?

select 
	product_line,
	sum(quantity) as qty
from sales 
group by 1
order by 2 desc

--Q4. What is the total revenue by month?

select 
	month_name as month,
	sum(total) as total_revenue
from sales
group by 1
order by 2 desc

--Q5. What month had the largest COGS?

select 
	sum(cogs) as cogs,
	month_name as months
from sales
group by 2
order by 1 desc 
limit 1

--Q6. What product line had the largest revenue?

select 
	product_line,
	sum(total) as total_revenue
from sales
group by 1
order by 2 desc

--Q7. What is the city with the largest revenue?

select 
	city,
	sum(total) as total_revenue
from sales
group by 1
order by 2 desc


--Q8. What product line had the largest VAT?

select * from sales

select 
	product_line,
	avg(tax_pct) as avg_tax
from sales 
group by 1
order by 2 desc

--Q9. Fetch each product line and add a column to those product line showing "Good", "Bad".
--Good if its greater than average sales

SELECT 
	product_line,
	AVG(quantity) AS avg_qnty
FROM sales
group by 1

select 
	product_line,
	case
		when avg(quantity) > 6 then 'GOOD'
		else 'BAD'
	end remark
from sales
group by 1

--Q10. Which branch sold more products than average product sold?

select 
	branch, 
    sum(quantity) as qnty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

--Q11. What is the most common product line by gender?

select 
	gender,
	product_line,
	count(gender)
from sales
group by 1,2
order by 3 desc

--Q12. What is the average rating of each product line

select 
	product_line,
	avg(rating)
from sales
group by 1


-----------------------------------------------------------------------------
---------------------------Sales Question ---------------------------------

--Q1. Number of sales made in each time of the day per weekday
select * from sales

select
	quantity,
	time_of_day,
	day_name
from sales
group by 1,2,3

--Q2. Which of the customer types brings the most revenue?

select 
	customer_type,
	sum(total) as total_revenue
from sales
group by 1
order by 2 desc

--Q3. Which city has the largest tax percent/ VAT (Value Added Tax)?

select 
	city,
	avg(tax_pct) as avg_txt
from sales
group by 1
order by 2 desc
	
--Q4. Which customer type pays the most in VAT?

select 
	customer_type,
	avg(tax_pct) as avg_txt
from sales
group by 1
order by 2 desc


----------------------------------------------------------------------------
---------------------------Customer Question ---------------------------------
--Q1. How many unique customer types does the data have?

select 
	distinct customer_type 
from sales

--Q2. How many unique payment methods does the data have?

select 
	distinct payment
from sales

--Q3. What is the most common customer type?

select 
	customer_type,
	count(*)
from sales
group by 1
order by 2 desc

--Q4. Which customer type buys the most?

select 
	customer_type,
	count(*)
from sales
group by 1

--Q5. What is the gender of most of the customers?

select 
	gender,
	count(*) as gndr_cnt
from sales
group by 1

--Q6. What is the gender distribution per branch?

select 
	gender,
	branch,
	count(*) as gndr_cnt
from sales
group by 1,2

--Q7. Which time of the day do customers give most ratings?
select * from sales

select 
	time_of_day,
	customer_type,
	avg(rating)
from sales
group by 1,2

--Q8. Which time of the day do customers give most ratings per branch?

select 
	time_of_day,
	branch,
	customer_type,
	avg(rating)
from sales
group by 1,2,3
order by 4
limit 1

--Q9. Which day fo the week has the best avg ratings?

select 
	day_name,
	avg(rating)
from sales
group by 1
order by 2 desc
limit 1

--Q10. Which day of the week has the best average ratings per branch?

select 
	day_name,
	branch,
	avg(rating)
from sales
group by 1,2
order by 2 desc
limit 1

-----------------------------------------------------------------------------




