--- 1. Who is the senior most employee based on job title?

SELECT 
    employee.first_name,employee.last_name,title
FROM 
    employee
WHERE 
    title LIKE '%Senior%';

--- 2. Which countries have the most Invoices?

select billing_country ,count(billing_country) as no_of_invoices
from invoice
GROUP by billing_country
order by no_of_invoices desc
	
--- 3. What are top 3 values of total invoice?

SELECT * 
from invoice	
order by total desc
limit 3

--- 4. Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals   

SELECT billing_city, sum(total) as total
from invoice
group by billing_city	
order by total desc

	
--- 5. Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money

select first_name,last_name,sum(total) as total_spend
from customer cu
join invoice inv on cu.customer_id = inv.customer_id
group by first_name,last_name
order by total_spend desc
limit 1

--- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A  

select distinct email,first_name,last_name
from customer cu
join invoice inv on cu.customer_id = inv.customer_id
join invoice_line invl on inv.invoice_id = invl.invoice_id
join track tr on invl.track_id = tr.track_id
join genre gr on tr.genre_id = gr.genre_id
WHERE gr.name = 'Rock'
order by email

--- 2. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands   

select distinct ar.name, count(tr.name) as total
from artist ar
JOIN album al on ar.artist_id = al.artist_id
JOIN track tr on al.album_id = tr.album_id
JOIN genre gr on tr.genre_id = gr.genre_id
WHERE gr.name = 'Rock'
GROUP by ar.name
order by total desc
limit 10


--- 3. Return all the track names that have a song length longer than the average song length.
--	Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select * from track

WITH t1 AS (
    SELECT name, milliseconds 
    FROM track
),
t2 AS (
    SELECT AVG(milliseconds) AS avg_length
    FROM track
)
SELECT t1.*
FROM t1, t2
WHERE t1.milliseconds > t2.avg_length
order by milliseconds desc


--- 1. Find how much amount spent by each customer on artists? Write a query to return 
--customer name, artist name and total spent.

select cu.first_name,cu.last_name,ar.name as artist_name, sum(invl.quantity*invl.unit_price) as total
from invoice_line invl 
JOIN invoice inv on invl.invoice_id = inv.invoice_id
join customer cu on inv.customer_id = cu.customer_id
join track tr on invl.track_id = tr.track_id
join album al on tr.album_id = al.album_id
join artist ar on al.artist_id = ar.artist_id
group by cu.first_name,cu.last_name,ar.name 
order by total desc


--- 2. We want to find out the most popular music Genre for each country. We determine the most popular
-- genre as the genre with the highest amount of purchases. Write a query that 
-- returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres.


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

SELECT * from invoice_line
--- 3. Write a query that determines the customer that has spent the most on music
--for each country. Write a query that returns the country along with the top
--customer and how much they spent. For countries where the top amount spent
--is shared, provide all customers who spent this amount.


WITH Customer_with_country AS (
    SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
           ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNO
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY 1,2,3,4
    ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM Customer_with_country where RowNo <= 1


