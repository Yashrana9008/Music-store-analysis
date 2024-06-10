create database music_store_analysis;
use music_store_analysis;
show tables;
select * from album2;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice_line;
select * from invoice;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

## Q1: Who is the senior most employee based on job title? 
select first_name,last_name,title from employee order by levels desc limit 1;

## Q2: Which countries have the most Invoices? 
select billing_country ,count(invoice_id) as no_of_invoice
from invoice group by billing_country 
order by no_of_invoice desc limit 10;

## Q3: What are top 3 values of total invoice? 
delimiter //
create procedure total_n(in N int)
begin
select * from invoice order by total desc limit N;
end //
delimiter ;

call total_n(3);

## Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
##     Write a query that returns one city that has the highest sum of invoice totals. 
##     Return both the city name & sum of all invoice totals
delimiter //
create procedure best_city(in N int)
begin 
select billing_city,sum(total) as invoice_total 
from invoice group by billing_city 
order by invoice_total desc limit N;
end //
delimiter ;
call best_city(1);
# Prague is the city which has best customers the store should throw a promotional music festival in Prague.

## Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
##     Write a query that returns the person who has spent the most money.

select c.first_name,c.last_name,c.city,sum(i.total) as total_spend 
from customer as c  join invoice as i on c.customer_id=i.customer_id 
group by c.first_name,c.last_name,c.city order by total_spend desc limit 1;

# FrantiÅ¡ek is the best customer from Prague with total spending of ~144.54

## Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
##     Return your list ordered alphabetically by email starting with A.

select c.email,c.first_name,c.last_name,g.name 
from customer as c join invoice as i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id 
join track as t on il.track_id=t.track_id 
join genre as g on t.genre_id=g.genre_id 
where g.name="Rock" order by c.email;

## Q7: Let's invite the artists who have written the most rock music in our dataset. 
##     Write a query that returns the Artist name and total track count of the top 10 rock bands.

select a.name,g.name,count(t.track_id) as total_track 
from artist as a join album2 as al on a.artist_id = al.artist_id 
join track as t on al.album_id = t.album_id 
join genre as g on t.genre_id = g.genre_id 
where g.name="Rock" group by a.name,g.name 
order by total_track desc limit 10;

## Q8: Return all the track names that have a song length longer than the average song length. 
##     Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select t.name,g.name,t.milliseconds from track as t 
join genre as g on t.genre_id = g.genre_id 
where t.milliseconds > ( select avg(milliseconds) from track) 
group by t.name,g.name,t.milliseconds 
order by t.milliseconds desc;

## Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select c.first_name,c.last_name,a.name as artist_name,sum(in_l.unit_price*in_l.quantity) as total_sales 
from customer as c join invoice as i on c.customer_id=i.customer_id
join invoice_line as in_l on i.invoice_id=in_l.invoice_id 
join track as t on in_l.track_id=t.track_id 
join album2 as a2 on t.album_id=a2.album_id 
join artist as a on a2.artist_id=a.artist_id 
group by c.first_name,c.last_name,a.name;


## Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
##      with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
##      the maximum number of purchases is shared return all Genres.

with popular_genre as
( select c.country,g.name,count(in_l.quantity)as purchases,
row_number() over(partition by c.country order by count(in_l.quantity) desc) as row_no from 
customer as c join invoice as i on c.customer_id=i.customer_id 
join invoice_line as in_l on i.invoice_id=in_l.invoice_id 
join track as t on in_l.track_id=t.track_id
join genre as g on t.genre_id=g.genre_id group by c.country,
g.name order by c.country asc, purchases desc) 
select * from popular_genre where row_no <=1;

## Q11: Write a query that determines the customer that has spent the most on music for each country. 
##      Write a query that returns the country along with the top customer and how much they spent. 
##      For countries where the top amount spent is shared, provide all customers who spent this amount.

select c.first_name,c.last_name,c.country,sum(i.total)as total_sepending 
from customer as c join invoice as i  
group by c.first_name,c.last_name,c.country 
order by c.country asc,
total_sepending desc;

