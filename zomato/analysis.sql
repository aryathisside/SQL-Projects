select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--Q1 What is the total amount each customer spent on zomato?

select
	s.userid,
	sum(p.price) as total_spent
from sales as s
join product as p on s.product_id = p.product_id
group by s.userid
order by s.userid

--Q2 How many days has each customer visited zomato 

select 
	userid,
	count(distinct created_date) as no_of_times_visited
from sales
group by 1
order by 1

	
--Q3 First product purchased by each customer
select * from 
(select s.*,
	row_number() over (partition by userid order by created_date ) as rowNum
from sales s) x
where x.rowNum <= 1

--Q4 What is the most purchased item on the menu and how many times was it purchased by all customers?

/*
-- Here first we found out which prodcut is purchased by using the inner query and 
--after that we checked that how many times was it purchased by each customer

*/
select userid,count(product_id ) as count_of_productId from sales where product_id = 
	( select 
		product_id
	from sales
	group by product_id
	order by count(product_id) desc
	limit 1
		)
group by userid


--Q5 which item was the most popular for the each customer

select product_id,count(product_id) from 
	(select 	
		s.*,
		row_number() over(partition by userid order by product_id)
	from sales s) x
group by userid,product_id

select product_id from 
(select 
	userid,
	product_id,
	count(product_id),
	row_number() over(partition by userid order by count(product_id) desc) rownum
 from sales 
group by product_id,userid
) x
where x.rownum <=1


--Q6 which item was purchased first by the customer after they became a member?

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

select * from 
	(select 
		x.userid,
		x.product_id,
		row_number() over(partition by x.userid) as rowNum
	from 
		(select 
			*,
			row_number() over(partition by userid order by created_date) as rowNum
		from sales) x
	join goldusers_signup as gold on x.userid = gold.userid
	where x.created_date > gold.gold_signup_date) y
where y.rowNum <= 1



--Q7 which item was purchased first by the customer before they became a member?
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

select * from 
	(select 
		x.userid,
		x.product_id,
		row_number() over(partition by x.userid) as rowNum
	from 
		(select 
			*,
			row_number() over(partition by userid order by created_date) as rowNum
		from sales) x
	join goldusers_signup as gold on x.userid = gold.userid
	where x.created_date < gold.gold_signup_date) y
where y.rowNum <= 1


--Q8 what is the total orders and amount spent for each member before 
-- they became a member?

select
	x.userid,
	count(x.product_id) as total_orders,
	sum(p.price) as total_spent
from
	(select 
		y.userid,
		y.product_id
	from
		(select s.* from sales s) y
	join goldusers_signup as gold on y.userid = gold.userid
	where y.created_date <= gold.gold_signup_date) x
join product as p on x.product_id = p.product_id
group by x.userid
order by x.userid


--Q9 If buying each product generated points for eg 5rs=2 zomato point and each
--prodcut has different purhcasing points for eg for p1 5rs=1 zomato point,
--for p2 10rs = 5 zomato point and p3 5rs =1 zomato point
--calculate points collected by each customers 


select userid,sum(total_points)*0.25 total_money_earned from
	(select points.*,amount/points as total_points from
		(select 
			amt.*, 
			case 
				when product_id =1 then 5
				when product_id =2 then 2
				when product_id =3 then 5
				else 0
			end as points 
		from 
			(select sale.userid,sale.product_id,sum(price) amount from 
				( select s.*,p.price
				  from sales s 
				  join product p on s.product_id = p.product_id) sale
			group by userid,product_id) amt) points
	order by userid,product_id) 
group by userid


--Q10 In the first one year after a customer joins the gold program(including their join date) irrespective
-- of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3
-- and what was their points earnings in their first year

select x.*,product.price from
	(select 
		s.userid,
		s.created_date,
		s.product_id,
		g.gold_signup_date
	from sales s 
	join goldusers_signup g 
	on s.userid = g.userid and created_date>=gold_signup_date and created_date<=DATE_ADD(gold_signup_date, INTERVAL 1 YEAR)
)x
join product on x.product_id = product.product_id






















	