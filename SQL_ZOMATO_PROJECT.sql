CREATE DATABASE RONIT 
--- ZOMATO PROJECT--
---CREATING TABLE ---

CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

SELECT * FROM goldusers_signup

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');
--2ND TABLE --
SELECT * FROM users

CREATE TABLE sales(userid int,created_date date,product_id int); 

INSERT INTO sales
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);
--3RD TABLE--
SELECT * FROM sales

CREATE TABLE product(product_id int,product_name varchar(30) , price int )

INSERT INTO product 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

--4th table --
select * from product

--TABLE LIST
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

---QUESTION---

# Q1: What is the total amount each customer spent on Zomato?

select 
s.userid, sum(p.price) as spent_amount
from sales s
inner join product p on  s.product_id = p.product_id
group by userid



# Q2: How many days each customer visited Zomato?

select userid,
count(distinct created_date) as visited_date
from sales
group by userid

# Q:3: What is the first product purchased by each of the customer?

select * from 
(select *,
rank() over(partition by userid order by created_date ) as ranking 
from sales) a where ranking =1

select*from sales

# Q4: what is most purchased item on the menu and how many times was it purchased by all the customer?

select userid, count(product_id) as count_p
from sales 
where product_id = 
(select top 1
product_id 
from sales
group by product_id
order by count
(product_id)desc
) 
group by userid


# Q5: Which item was most favorate from each of the cusrtomer?

select * from 
(select *,
rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id, count(product_id) cnt
from sales
group by userid,product_id)a)b
where rnk=1



 Q6: which item was first purchased by the customer after they beacome a member?

select* from (
select *, rank() over(partition by userid order by created_date)rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date >= gold_signup_date) as a) b
where rnk = 1



#7: Which item was purchased  just before the customer become a member?

select* from (
select *, rank() over(partition by userid order by created_date desc)rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date <= gold_signup_date) as a) b
where rnk =1




# Q8: What is the total order and amount spent for each member before they become a member?

select userid, count(created_date) as order_purchased, sum(price)as total_amount_spent from
(select a.*, b.price from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date <= gold_signup_date)a 
inner join product b 
on a.product_id = b.product_id)c
group by userid


# Q9:  If buying each products generates points for eg 5rs = 2 Zomato points and
each  each product has diferent purchasinng points for eg. p1 5rs=1 Zomato point, for p2 
10rs=5 Zomato point and p3 5rs=1 Zomato point
Calculate points collect by each customer and for which product most points has been given till now


select userid, sum(total_points) * 2.5 as total_points_earned from 
(select c.*, amount/ points as total_points from
(select b.*, case when product_id = 1 then 5
when product_id = 2 then 2
when product_id=3 then 5 
else 0 end as  points from
(select a.userid, a.product_id, sum(price) as amount from
(select s.*, p.price
from sales as s
inner join product as p
on s.product_id = p.product_id)a
group by userid, product_id)b)c)d
group by userid

# Q10: In the first one year after a customer joins the gold program (including their join date) irrespective
of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3
and what was their points earnings in thier first yr?
1 zp=2rs
0.5 zp 1rs

select * from goldusers_signup;

select c.*,d.price * 0.5 total_points_earned from
(select a.userid, a.created_date,a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and created_date <=DATEADD (year,1,gold_signup_date))c
inner join product d on c.product_id=d.product_id

