-- ZOMATO QUERY 📝
select * from sales; 
select * from product;
select * from goldusers_signup;
select * from users;



-- What is the total amount each customer spent on zomato?
select sales.userid, sales.product_id, product.price from sales inner join product on sales.product_id=product.product_id;

select sales.userid, sum(product.price) as total_spending from sales inner join product on sales.product_id=product.product_id group by sales.userid;

-- How many days has each customer visited zomato?
select userid,count(created_date) as no_of_days from sales group by userid;
select userid,count(distinct created_date) as no_of_days from sales group by userid;

-- What was the first product purchased by each customer?
select *, rank() over (partition by userid order by created_date ) as "rank"  from sales;
select * from (select *, rank() over (partition by userid order by created_date ) as "rank" from sales)  where "rank" =1;


-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_id,count(product_id)  from sales group by product_id order by count(product_id) desc limit 1;


-- which item was the most popular for each customer?


select *, rank() over (partition by userid order by product_count desc) as "rank" 
from (select userid, product_id, count(product_id) as product_count from sales group by userid, product_id);

select * from
(
select *, rank() over (partition by userid order by product_count desc) as "rank" 
from (select userid, product_id, count(product_id) as product_count from sales group by userid, product_id)
) where "rank"=1;

-- Which item was purchased first by the customer after they became a gold member? 


select * from 
(
select *,rank() over (partition by userid order by created_date) as rnk from 
(select a.userid,a. created_date,a.product_id,b.gold_signup_date from sales as a inner join goldusers_signup as b on a.userid=b.userid
and created_date >= gold_signup_date
) as temp
) as tempp where rnk=1;


-- Which item was purchased just before the customer became a member?

select * from 
(
select *,rank() over (partition by userid order by created_date desc) as rnk from 
(select a.userid,a. created_date,a.product_id,b.gold_signup_date from sales as a inner join goldusers_signup as b 
on a.userid=b.userid
and created_date < gold_signup_date
) as temp
) as tempp where rnk=1;

-- what is the total orders and amount spent for each member before they became a member?

select a.* ,b.product_id,b.price from  
(
select a.userid,a. created_date,a.product_id from sales as a inner join goldusers_signup as b 
on a.userid=b.userid
and created_date < gold_signup_date
) as a 
inner join 
product as b on a.product_id=b.product_id;



select  userid,count(created_date) as total_orders ,sum(price) as amount_spend from 
(
select a.* ,b.product_id as product_id_b , b.price from  
(
select a.userid,a. created_date,a.product_id from sales as a inner join goldusers_signup as b 
on a.userid=b.userid
and created_date < gold_signup_date
) as a 
inner join 
product as b on a.product_id=b.product_id
) as t
group by userid;



-- If buying each product generates points for eg 5rs-2 zomato point and each product has different purchasing points
-- for eg for p1 5rs=1 zomato point ,for p2 10rs-5zomato point and p3 5rs-1 zomato point.
-- A)-Calculate points collected by each customers.
-- B)-for which product most points have been given till now. 

-- A)
select userid, sum(points_earned) as total_money_earned from
( 
select e.*, amount/points as points_earned from 
(
select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from 
(
select c.userid, c.product_id, sum(c.price) as amount from
(
select a.*, b.price from sales as a inner join product as b on a.product_id=b.product_id
)as c
group by userid,product_id
) as d
) as e
) as f group by userid;

-- --B)
select product_id, sum(points_earned) as money_earned_from_per_product from 
( 
select e.*, amount/points as points_earned from 
(
select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from 
(
select c.userid, c.product_id, sum(c.price) as amount from
(
select a.*, b.price from sales as a inner join product as b on a.product_id=b.product_id
)as c
group by userid,product_id
) as d
) as e
) as f group by product_id order by money_earned_from_per_product desc limit 1;

-- 10- In the first one year after a customer joins the gold program (including their join date) 
-- irrespective of what the customer has purchased 
-- they earn 5 zomato points for every 10 rs spent who earned more more 1 or 3
-- and what was their points earnings in thier first yr? 

select c.*, c.total_spending/2 as points_earned from
(
select userid,sum(price) as total_spending  from
(
select a.*,b.price from
(
select a.*, b.gold_signup_date from sales as a inner join goldusers_signup as b on a.userid=b.userid 
where created_date>=gold_signup_date  and created_date <= DATE_ADD(gold_signup_date,interval 1 year)
) as a
inner join  product as b on a.product_id=b.product_id
) as b 
 group by userid
 ) as c;

-- rank all the transaction of the customers

select * ,rank() over (partition by userid order by created_date) as rnk from sales;

-- rank all the transactions for each member whenever
-- they are a zomato gold member for every non gold member transction mark as NA


select a.*, case when gold_signup_date is null then 0 else rank() over (partition by userid order by created_date desc )end as rnk  from 
(
select a.*, b.gold_signup_date from sales as a left join goldusers_signup as b on a.userid=b.userid and created_date>=gold_signup_date
)as a;










