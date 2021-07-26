--Task 3a.)

--Report 1 (Top k = 10)
--a.)What is the total number of rent for properties of each suburb in VIC?

--b.) Explanation: This query will help users to explore popular Victorian suburbs
--for rental properties.

--c.) SQL commands

select s.state_name, a.suburb, count(f.total_number_of_rent) as total_number_of_rent
from MonRE_rent_fact_v2 f, address_dim_v2 a, postcode_dim_v2 p, state_dim_v2 s, property_dim_v2 pr
where f.property_id = pr.property_id and pr.address_id = a.address_id
and a.postcode = p.postcode and p.state_code = s.state_code
and s.state_code = 'VIC'
group by s.state_name, a.suburb
order by total_number_of_rent desc
fetch next 10 rows only;

--Report 2 (Top n% = 10)
--a.)What is the total number of rent for properties of each suburb in NSW?

--b.)Explanation: This query will help users to explore popular New South Wales 
--suburbs for rental properties.

--c.)SQL commands
select s.state_name, a.suburb, count(f.total_number_of_rent) as total_number_of_rent
from MonRE_rent_fact_v2 f, address_dim_v2 a, postcode_dim_v2 p, state_dim_v2 s, 
property_dim_v2 pr
where f.property_id = pr.property_id and pr.address_id = a.address_id
and a.postcode = p.postcode and p.state_code = s.state_code
and s.state_code = 'NSW'
group by s.state_name, a.suburb
order by total_number_of_rent desc
fetch first 10 percent rows only;

--Report 3 (Show All)
--a.)What is the total number of rent for properties by State?

--b.)Explanation: This query will help users to view 
--MonRE's total rental properties for all states

--c.)SQL commands
select s.state_name, 
count(f.total_number_of_rent) as total_number_of_rent
from MonRE_rent_fact_v2 f, address_dim_v2 a, postcode_dim_v2 p, state_dim_v2 s, 
property_dim_v2 pr
where f.property_id = pr.property_id and pr.address_id = a.address_id
and a.postcode = p.postcode and p.state_code = s.state_code
group by s.state_name
order by total_number_of_rent desc;

-- Task 3b.)

--Report 4 (Cube Operator)
--a.)What are the sub-total and total rental fees from each suburb, time period, 
--and property type? 

--b.)Explanation: This query will provide management with information relating
-- to the top rental property types for each suburb at a given time.

--c.)SQL commands
select a.suburb, pr.property_type, f.rent_start_date,
sum(f.total_rental) as Total_Rental_Fees,
case grouping_id(a.suburb, f.rent_start_date, pr.property_type)
when 0 then ''
when 1 then 'Time subtotal'
when 2 then 'Property Type subtotal'
when 3 then 'Suburb Total'
end as subtotals
from address_dim_v2 a, property_dim_v2 pr, MonRE_rent_fact_v2 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
and f.rent_start_date is not null
group by cube (a.suburb, f.rent_start_date, pr.property_type)
order by a.suburb;

--Report 5 (Partial Cube Operator)
--a.)What are the sub-total and total rental fees from each suburb, time period, 
--and property type? 

--b.)Explanation: This query will provide management with information relating
-- to the top rental property types for each suburb at a given time.

--c.)SQL commands
select decode(grouping(a.suburb), 1, 'All Suburbs', a.suburb) as Suburb,
decode(grouping(f.rent_start_date), 1, 'All Dates', f.rent_start_date) as Rental_Date, 
decode(grouping(pr.property_type), 1, 'All Property Type', pr.property_type) as Property_Type,
sum(f.total_rental) as Total_Rental_Fees
from address_dim_v2 a, property_dim_v2 pr, MonRE_rent_fact_v2 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
group by cube (a.suburb, f.rent_start_date), pr.property_type
order by f.rent_start_date;

--Report 6 (Roll-up Operator)
--a.)What are the sub-total and total rental fees from each state, and 
--property type? 

--b.)Explanation: This query will be usefull for management to explore
-- information relating to property type rentals based on different States

--c.)SQL commands
select decode(grouping(s.state_name), 1, 'All States', s.state_name) as State_Name,
decode(grouping(pr.property_type), 1, 'All Property Type', pr.property_type) as Property_Type,
sum(f.total_rental) as Total_Rental_Fees
from address_dim_v2 a, state_dim_v2 s, postcode_dim_v2 p,  
property_dim_v2 pr, MonRE_rent_fact_v2 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
and a.postcode = p.postcode and p.state_code = s.state_code
group by rollup (s.state_name, pr.property_type)
order by Total_Rental_Fees asc;

--Report 7 (Partial Roll-up Operator)
--a.)What are the sub-total and total rental fees from each state, and 
--property type? 

--b.)Explanation: This query will be usefull for management to explore
-- information relating to property type rentals based on different States

--c.)SQL commands
select decode(grouping(s.state_name), 1, 'All States', s.state_name) as State_Name,
decode(grouping(pr.property_type), 1, 'All Property Type', pr.property_type) as Property_Type,
sum(f.total_rental) as Total_Rental_Fees
from address_dim_v2 a, state_dim_v2 s, postcode_dim_v2 p,  
property_dim_v2 pr, MonRE_rent_fact_v2 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
and a.postcode = p.postcode and p.state_code = s.state_code
group by rollup (s.state_name), pr.property_type
order by Total_Rental_Fees asc;

--Report 8
--a.)What is the total number of clients and cumulative number of clients with a
--high budget in each year?(cumulative aggregates)

--b.)Explanation: This query will inform the user about the number of high 
-- budgeted clients for each year

--c.)SQL commands
select fr.rent_start_date, count(fr.total_number_of_clients) as Total_Number_of_Rental_Clients,
to_char(count(count(fr.total_number_of_clients)) over(partition by fr.rent_start_date
order by rent_start_date rows unbounded preceding), '9,999,999.99') 
as Cumulative_number_of_rental_clients, 
fs.sale_date, count(fs.total_number_of_clients) as Total_Number_of_Sales_Client,
to_char(count(count(fs.total_number_of_clients)) over(partition by fs.sale_date
order by sale_date rows unbounded preceding), '9,999,999.99') 
as Cumulative_number_of_rental_clients
from MonRE_rent_fact_v2 fr, MonRE_sale_fact_v2 fs, 
property_dim_v2 pr, client_dim_v2 c
where c.min_budget > 100001 and
pr.property_id = fr.property_id and pr.property_id = fs.property_id 
group by fr.rent_start_date, fs.sale_date;

--Report 9
--a.)What is the total rental fees and cumulative rental fees by property type in
--each rental date? (cumulative aggregate)

--b.)Explanation: This query will help Managers in examining the trend of rental 
--properties among tenants, and by Rental Date to know the contribution 
--of rental fees in total for a particular Rental Date

--c.)SQL command
select fr.rent_start_date, pr.property_type, sum(fr.total_rental) as Total_Rental,
to_char(sum(sum(fr.total_rental)) over(order by fr.rent_start_date 
rows unbounded preceding), '9,999,999.99') 
as Cumulative_rental_fees
from MonRE_rent_fact_v2 fr, property_dim_v2 pr
where fr.property_id = pr.property_id
group by fr.rent_start_date, pr.property_type
order by rent_start_date;

--Report 10
--a.)What is the total rental fees and moving aggregate rental fees by property type in
--each month of the year? (moving aggregate)

--b.)Explanation: This query is particularly useful in understanding the rental 
--properties trend among tenant by date and to know the contribution in average
--by date

--c.)SQL command
select fr.rent_start_date, pr.property_type, sum(fr.total_rental) as Total_Rental,
to_char(avg(sum(fr.total_rental)) over(order by fr.rent_start_date 
rows 2 preceding), '9,999,999.99') 
as Moving_aggregate_rental_fees
from MonRE_rent_fact_v2 fr, property_dim_v2 pr
where fr.property_id = pr.property_id
group by pr.property_type, fr.rent_start_date
order by fr.rent_start_date;

--Report 11 (Ranking)
--a.)Show ranking of each property type based on the yearly total number of 
--sales and the ranking of each state based on the yearly total number of sales.

--b.)Explanation: This query is useful for management to analyse MonRE
--based on property type and state to explore most active markets for properties

--c.)SQL command
select f.sale_date, pr.property_type, s.state_name, 
count(f.total_number_of_sale) as Total_number_of_sales, 
rank()over (partition by pr.property_type order by count(f.total_number_of_sale)desc)
as rank_by_property_type,
rank()over (partition by s.state_name order by count(f.total_number_of_sale)desc)
as rank_by_state
from MonRE_sale_fact_v2 f, property_dim_v2 pr, state_dim_v2 s,
postcode_dim_v2 po, address_dim_v2 a
where f.property_id = pr.property_id and 
pr.address_id = a.address_id and a.postcode = po.postcode and
po.state_code = s.state_code
group by f.sale_date, pr.property_type, s.state_name
order by s.state_name;

--Report 12
--a.)Show ranking of each property size on the total number of 
--sales and the ranking of each suburb on the total number of sales.

--b.)Explanation: this query is useful for management to analyse the MonRE
--based on property size and the suburb that it has been able to most actively market
--properties

--c.)SQL command
select f.sale_date, pr.property_size, a.suburb, 
count(f.total_number_of_sale) as Total_number_of_sales, 
rank()over (partition by pr.property_size order by count(f.total_number_of_sale)desc)
as rank_by_property_size,
rank()over (partition by a.suburb order by count(f.total_number_of_sale)desc)
as rank_by_suburb
from MonRE_sale_fact_v2 f, property_dim_v2 pr, address_dim_v2 a
where f.property_id = pr.property_id and
pr.address_id = a.address_id
group by f.sale_date, pr.property_size, a.suburb
order by a.suburb;









