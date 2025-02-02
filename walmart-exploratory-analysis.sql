use walmart_db;
show tables;
select * from walmart;
select count(*) from walmart;

-- Finding out the distinct payment_method types in the table--
Select distinct(payment_method) from walmart;

-- Finding the total number of transactions for each payment_method type---
Select payment_method,count(*) from walmart group by payment_method;

-- Finding the count of distinct branches--
Select Count(distinct(Branch)) from walmart;

-- Max quantities in the table--
select max(quantity) from walmart;

-- Min quantities in the table--
select min(quantity) from walmart;

-- Business problems --
-- 1: Find different payment method and number of transactions, number of qty sold --

Select payment_method,
count(*) as no_of_transactions,
 sum(quantity)  as total_quantity 
 from walmart group by payment_method;
 
 -- 2: Find the highest rated category in each branch, displaying the branch , category and avg rating--
 Select Branch , category, avg(rating) as avg_rating from walmart group by Branch, category order by Branch, avg(rating) desc ;
 -- The above code will give the average rating from desc to asc for each categories for each branch--
 
 Select Branch,category, avg(rating) as avg_rating, RANK() OVER(partition by Branch ORDER BY AVG(rating) desc) 
 as rank_value from walmart
 group by Branch,category;
 -- The above code will assign a rank to each avg rating for each category for each branch--
 
 -- Using a subquery to filter out the first rank from the above query--
 
 Select * from 
 (
		Select 
				Branch,category, avg(rating) as avg_rating, RANK() OVER(partition by Branch ORDER BY AVG(rating) desc) as rank_value 
                from walmart
				group by Branch,category
) as rank_reports
where rank_value=1;

-- 3: Identify the busiest day for each branch based on the number of transactions --
Select * from (
  Select 
	Branch,
    DAYNAME(STR_TO_DATE(date,'%d-%m-%Y')) as day_name,
    COUNT(*) as no_transactions,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as rank_value
    from walmart
    group by Branch, day_name
    ) as final_table
where rank_value=1;

-- 4: Calculate the total quantity of items sold per payment method. list payment_method and total_quantity --

Select payment_method, sum(quantity) as total_quantity from walmart group by payment_method;

-- 5: Determine the average, minimum, and max rating of category for each city. List the city, average_rating, min_rating and max_rating.--

Select city, category,avg(rating) as average_rating, min(rating) as min_rating, max(rating) as max_rating from walmart group by city,category;


/* 6: Calculate the total price for each category by considering total profit as 
(unit price *quantity * profit_margin). List category and total profit, ordered from highest to lowest profit */

Select category, SUM(total) as total_revenue, SUM(total * profit_margin) as total_price from walmart group by category order by total_price desc;

/* 7: Determine the most common payment method for each branch. Display branch and the preferred_payment_method.*/
Select * from
(Select 
    Branch,
    payment_method,
    count(*) as total_trans,
    rank() over(partition by Branch order by count(*) desc) as rank_value
    from walmart 
group by Branch, payment_method) as final_table
where rank_value=1;

/* 8: Categorize sales into 3 group morning,afternoon, evening. Find out each shift and the number of invoices */

Select
   Branch, 
   Case
		When hour(str_to_date(walmart.time, '%H:%i:%s')) < 12 then 'Morning'
        When hour(str_to_date(walmart.time, '%H:%i:%s')) between 12 and 17 then 'Afternoon'
        else 'Evening'
	end day_time,
    Count(*) as no_of_invoices
from walmart
group by day_time, Branch
order by Branch, no_of_invoices desc;

/* Identify 5 branches with highest decrease ratio in revenue compared to last year
(current year is 2023) */
 -- revenue_decrease_ratio = last_revenue- current_revenue/ last_revenue *100 --
 
 Select 
	*,
   Year(STR_TO_DATE(date,'%d-%m-%Y')) as formatted_date
from walmart;

-- 2022 sales --
with revenue_2022
as
(
	Select 
		Branch,
		Sum(total) as revenue
	from walmart
	where Year(STR_TO_DATE(date,'%d-%m-%Y')) =2022
	group by branch
),
revenue_2023
as
(
Select 
		Branch,
		Sum(total) as revenue
	from walmart
	where Year(STR_TO_DATE(date,'%d-%m-%Y')) =2023
	group by branch
)

Select 
	ls.branch,
    ls.revenue as last_year_revenue,
    cs.revenue as curr_year_revenue,
    round(((ls.revenue - cs.revenue)/ ls.revenue) * 100,2) as decrease_percent_ratio
from revenue_2022 as ls
inner join 
revenue_2023 as cs 
on ls.Branch = cs.Branch
where ls.revenue >  cs.revenue
order by decrease_percent_ratio desc
limit 5;




 
