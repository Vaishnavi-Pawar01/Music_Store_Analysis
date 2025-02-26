/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
select*from employee
order by levels desc 
limit 1;

/* Q2: Which countries have the most Invoices? */
select count(total) as invoices_count , billing_country 
from invoice
group by billing_country
order by invoices_count desc ;

/* Q3: What are top 3 values of total invoice? */
select total 
from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select sum(total) as invoice_total , billing_city
from invoice 
group by billing_city
order by invoice_total desc
limit 1 ;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.first_name ,c.customer_id, sum(i.total) as invoice_total
from customer c
join invoice i 
on c.customer_id =i.customer_id
group by c.customer_id , c.first_name
order by invoice_total desc
limit 1;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select c.first_name, c.last_name , c.email,g.name
from customer c
join invoice i 
on c.customer_id =i.customer_id 
join invoice_line il  
on i.invoice_id =il.invoice_id 
join track t
on il.track_id = t.track_id
join  genre g
on t.genre_id = g.genre_id
where g.name = 'rock'
 order by c.email  ; 
 
 
/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.artist_id ,ar.name , count(ar.artist_id) as track_count
from track t
join album a
on t.album_id = a.album_id
join artist ar
on ar.artist_id=a.artist_id
join genre g
on t.genre_id = g.genre_id 
where g.name = 'rock'
group by ar.artist_id ,ar.name
order by  track_count desc 
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name , milliseconds 
from track 
where milliseconds >(select avg(milliseconds) as avg_song_length from track)
order by milliseconds desc ;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

with best_selling_artist as ( select ar.artist_id , ar.name as artist_name , sum(il.unit_price*il.quantity) as total_sale 
							from invoice_line il 
                            join track t 
                            on il.track_id = t.track_id 
                            join album al 
                            on al.album_id = t.album_id
                            join artist ar 
                            on ar.artist_id = al.artist_id
                            group by 1 ,2
                            order by total_sale desc )
	select c.first_name , bsa.artist_name,sum(il.unit_price*il.quantity) as total_sale 
    from invoice i
    join customer c 
    on i.customer_id=c.customer_id
    join invoice_line il
    on i.invoice_id=il.invoice_id 
    join track t 
    on t.track_id=il.track_id
    join album al
    on  al.album_id= t.album_id
    join best_selling_artist bsa
    on bsa.artist_id=al.artist_id
    group by 1,2
    order by total_sale desc ; 
    
    /* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

with most_popular_genre as ( select count(il.quantity)as purchases ,c.country, g.name,g.genre_id,
						row_number() over(partition by c.country order by count(il.quantity) desc ) as row_num
						from invoice_line il
                        join invoice i 
                        on il.invoice_id = i.invoice_id 
                        join customer c
                        on c.customer_id =i.customer_id 
                        join track t 
                        on t.track_id = il.track_id 
                        join genre g
                        on g.genre_id = t.genre_id
                        group by 2,3,4
                        order by 2 asc , 1 desc  )
  select* from most_popular_genre   where row_num<= 1  ;
  
  /* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

with  Customter_with_country AS (
		select c.customer_id,c.first_name,c.last_name,i.billing_country,SUM(i.total) as total_spending,
	    row_number() over(partition by  billing_country order by  SUM(total) desc) as Row_No 
		from invoice i
		join  customer c 
        on c.customer_id = i.customer_id
		group by 1,2,3,4
		order by  4 asc,5 desc)
select  * FROM Customter_with_country WHERE Row_No <= 1;

select concat(first_name," ",last_name)as patient_name ,
round((height/30.48),1)as height,round(weight*2.205)as weight,birth_date,
case 
when gender='F' then 'female'
when gender ='M' then 'male'
end as gender_type
from patients;
  
  




				
                                