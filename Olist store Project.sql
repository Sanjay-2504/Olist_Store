
 use olist_store_analysis;
 SET SQL_SAFE_UPDATES=0;
 
 select * from olist_store_analysis.olist_orders_dataset;
 
 # 1. Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
 create view Payment_Statistics as
 select
 case 
 when dayname(order_purchase_timestamp) = "sunday" or "saturday" then "Weekend" else "Weekday" end  as DayType
,Count(Price) as Total_Orders
 from olist_store_analysis.olist_orders_dataset  as O
 inner join olist_store_analysis.olist_order_items_dataset as I
 on O.order_id = I.Order_id
 group by DayType;
 
 select * from  payment_statistics;
------

alter table olist_store_analysis.olist_orders_dataset
add column day_type varchar(100);
update olist_orders_dataset
set day_type = if(Dayofweek(order_purchase_timestamp)in	(1,7),'WEEKEND','WEEKDAY');

select day_type, round(sum(payment_value)) as 'Total Payment'
from olist_store_analysis.olist_orders_dataset od join olist_store_analysis.olist_order_payments_dataset op on od.order_id=op.order_id
group by day_type;

# 2.Number of Orders with review score 5 and payment type as credit card.

create view review_score_5_and_payment_type_credit_card as (
select count(r.order_id )
from olist_order_reviews_dataset as r
inner join olist_order_payments_dataset p on r.order_id = p.order_id
where review_score = 5 AND payment_type= 'credit_card');

select * from review_score_5_and_payment_type_credit_card;

# 3.Average number of days taken for order_delivered_customer_date for pet_shop
create view Number_of_days as (
select p.product_category_name,
floor(avg(Datediff(order_delivered_customer_date,order_purchase_timestamp))) as Days_diff
from olist_store_analysis.olist_order_items_dataset as I
inner join olist_store_analysis.olist_orders_dataset  as o
on o.order_id = I.order_id
inner join olist_store_analysis.olist_products_dataset as P
on I.product_id = p.product_id
where p.product_category_name = "pet_shop"
Group by p.product_category_name);

select * from number_of_days;

# 4.Average price and payment values from customers of sao paulo city
create view Avg_Price_Payment_sao_paulo as (
select c.customer_city  as city_name,
floor(avg(i.price)) as Avg_Price ,
floor(avg(p.payment_value)) as Avg_payment_value
from olist_store_analysis.olist_orders_dataset  as o
inner join olist_store_analysis.olist_customers_dataset as c
on o.customer_id = c.customer_id
inner join olist_store_analysis.olist_order_payments_dataset as p
on o.order_id = p.order_id
inner join olist_store_analysis.olist_order_items_dataset as i
on o.order_id = i.order_id
where c.customer_city = "sao paulo"
group by c.customer_city ); 

select * from avg_price_payment_sao_paulo;


# 5.Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.


select 
review_score,
avg(Datediff(order_delivered_customer_date,order_purchase_timestamp)) as AVG_Days_difference
from olist_store_analysis.olist_orders_dataset as o
inner join
olist_store_analysis.olist_order_reviews_dataset as r
on o.order_id = r.order_id
Group by review_score;
