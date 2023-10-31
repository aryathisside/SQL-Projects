--SET 1 EASY
select * from employee

-- Q1 Who is the senior most employee based on job title?
select Concat(first_name,'', last_name) from employee
order by levels desc
limit 1

--Q2 Which countries have the most Invoices?
select * from invoice

select 
	billing_country,
	sum(total) as total_invoice
from invoice
group by billing_country

--Q3 What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3

--Q4 Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals

select 
	billing_city,
	sum(total) as total_invoice
from invoice 
group by billing_city
order by total_invoice desc
limit 1

--Q5 Who is the best customer? 
-- The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money

select 
	c.first_name,
	sum(i.total) as total
from customer as c
join invoice as i 
on c.customer_id = i.customer_id
group by first_name
order by total desc
limit 1

--SET 2 Moderate

--Q1 Write query to return the email, first name, last name, & 
-- Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

select 
	c.email,
	c.first_name,
	c.last_name,
	g.name 
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on t.track_id = il.track_id
join genre as g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email

--Q2 Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
select * from artist 
select track_id,name from track 
select 
	a.name,
	count(t.track_id) as total_tracks
from artist as a
join album as alb on a.artist_id = alb.artist_id
join track as t on alb.album_id = t.album_id
group by a.name
order by total_tracks desc
limit 10


--Q3 Return all the track names that have a song length longer than the average 
-- 'song length. Return the Name and Milliseconds for each track. 
-- Order by the song length with the longest songs listed first
select name,milliseconds from track 

select 
	name,
	milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_length from track )
order by milliseconds desc

--SET 3 Advance

-- Q1 Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent
/*First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- --Q2 We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

--Q3 Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount

select * from(
	select 
		i.billing_country,
		c.first_name,
		sum(total) as total_spent,
		row_number() over(partition by billing_country order by sum(total) desc) as rowNum
	from invoice i
		join customer c on c.customer_id = i.customer_id
		group by 1,2
		order by 1 ASC, 3 DESC
	) x
where x.rowNum <= 1
	
	

























