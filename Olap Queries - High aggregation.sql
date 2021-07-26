--Task 3a.)

--Report 1
--a.)What is the total number of sale for properties of each suburb in VIC?

--b.) Explanation: This query will help users to understand the market scope for properties
--in each suburb in Victoria

--c.) SQL commands
select s.state_name, a.suburb, count(f.total_number_of_sale) as total_number_of_sales
from monre_sale_fact_v1 f, address_dim a, postcode_dim p, state_dim s, property_dim pr
where f.property_id = pr.property_id and pr.address_id = a.address_id
and a.postcode = p.postcode and p.state_code = s.state_code
and s.state_code = 'VIC'
group by s.state_name, a.suburb, f.total_number_of_sale
order by total_number_of_sales desc
fetch next 20 rows only;

--Report 2
--a.)What is the total number of sales for properties of each suburb in NSW?

--b.)Explanation: This query will help users to understand the market scope for properties
--in each suburb in New South Wales

--c.)SQL commands
select s.state_name, a.suburb, count(f.total_number_of_sale) as total_number_of_sales
from monre_sale_fact_v1 f, address_dim a, postcode_dim p, state_dim s, property_dim pr
where f.property_id = pr.property_id and pr.address_id = a.address_id
and a.postcode = p.postcode and p.state_code = s.state_code
and s.state_code = 'NSW'
group by s.state_name, a.suburb, f.total_number_of_sale
order by total_number_of_sales desc
fetch first 5 percent rows only;

--Report 3
--a.)What is the total number of sales for property by scale in Victoria?*/

--b.)Explanation: This query will help users to understand the market scope of 
--each type of property in Victoria

--c.)SQL commands
select s.state_name, pr.property_type, 
count(f.total_number_of_sale) as total_number_of_sales 
from monre_sale_fact_v1 f, address_dim a, postcode_dim p, state_dim s, property_dim pr
where f.property_id = pr.property_id and pr.address_id = a.address_id
and a.postcode = p.postcode and p.state_code = s.state_code
and s.state_code = 'VIC'
group by s.state_name, pr.property_type, f.total_number_of_sale
order by total_number_of_sales desc;

-- Task 3b.)

--Report 4
--a.)What are the sub-total and total rental fees from each suburb, time period, 
--and property type? (Use Cube)

--b.)Explanation: This query will help give information to management on the 
--top renting property type at each suburb at a particular time

--c.)SQL commands
select a.suburb, t.time_rent_id as period, pr.property_type, 
sum(f.total_rental) as Total_Rental_Fees
from address_dim a, time_rent_dim t, property_dim pr, monre_rent_fact_v1 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
and f.time_rent_id = t.time_rent_id
group by cube (a.suburb, t.time_rent_id, pr.property_type)
order by t.time_rent_id;

--Report 5
--a.)What are the sub-total and total rental fees from each suburb, time period, 
--and property type? (Use Partial Cube)

--b.)Explanation: This query will help give information to management on the 
--top renting property type at each suburb at a particular time

--c.)SQL commands
select decode(grouping(a.suburb), 1, 'All Suburbs', a.suburb) as Suburb,
decode(grouping(t.time_rent_id), 1, 'All Periods', t.time_rent_id) as Period, 
decode(grouping(pr.property_type), 1, 'All Property Type', pr.property_type) as Property_Type,
sum(f.total_rental) as Total_Rental_Fees
from address_dim a, time_rent_dim t, property_dim pr, monre_rent_fact_v1 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
and f.time_rent_id = t.time_rent_id
group by cube (a.suburb, t.time_rent_id), pr.property_type
order by t.time_rent_id;

--Report 6
--a.)What are the sub-total and total rental fees from each state, time period, and 
--property scale? (use Roll-up)

--b.)Explanation: This query will be usefull for management to type the top selling 
--property scale by each state at a particular time and understand 
--buyer preference by state.

--c.)SQL commands
select decode(grouping(s.state_name), 1, 'All States', s.state_name) as State_Name,
decode(grouping(t.time_rent_id), 1, 'All Periods', t.time_rent_id) as Period, 
decode(grouping(pr.property_scale), 1, 'All Property Scale', pr.property_scale) as Property_Scale,
sum(f.total_rental) as Total_Rental_Fees
from address_dim a, state_dim s, postcode_dim p, time_rent_dim t, 
property_dim pr, monre_rent_fact_v1 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
and a.postcode = p.postcode and p.state_code = s.state_code
and f.time_rent_id = t.time_rent_id
group by rollup (s.state_name, t.time_rent_id, pr.property_scale)
order by t.time_rent_id;

--Report 7
--a.)What are the sub-total and total rental fees from each state, time period, and 
--property scale? (use Partial Roll up)

--b.)Explanation: This query will be usefull for management to type the top selling 
--property scale by each state at a particular time and understand 
--buyer preference by state.

--c.)SQL commands
select decode(grouping(s.state_name), 1, 'All States', s.state_name) as State_Name,
decode(grouping(t.time_rent_id), 1, 'All Periods', t.time_rent_id) as Period, 
decode(grouping(pr.property_scale), 1, 'All Property Scale', pr.property_scale) as Property_Scale,
sum(f.total_rental) as Total_Rental_Fees
from address_dim a, state_dim s, postcode_dim p, time_rent_dim t, 
property_dim pr, monre_rent_fact_v1 f
where f.property_id = pr.property_id and pr.address_id = a.address_id 
and a.postcode = p.postcode and p.state_code = s.state_code
and f.time_rent_id = t.time_rent_id
group by rollup (s.state_name, t.time_rent_id), pr.property_scale
order by t.time_rent_id;

--Task 3c

--Report 8
--a.)What is the total number of clients and cumulative number of clients with a
--high budget in each year?(cumulative aggregates)

--b.)Explanation: This query helps to identify the type of property to represent
--or acquire based on the client budget capacity.

--c.)SQL commands
select tr.time_rent_year, count(fr.total_number_of_clients) as Total_Number_of_Rental_Clients,
to_char(count(count(fr.total_number_of_clients)) over(partition by tr.time_rent_year
order by time_rent_year rows unbounded preceding), '9,999,999.99') 
as Cumulative_number_of_rental_clients, 
ts.time_sale_year, count(fs.total_number_of_clients) as Total_Number_of_Sales_Client,
to_char(count(count(fs.total_number_of_clients)) over(partition by ts.time_sale_year
order by time_sale_year rows unbounded preceding), '9,999,999.99') 
as Cumulative_number_of_rental_clients
from monre_rent_fact_v1 fr, time_rent_dim tr, monre_sale_fact_v1 fs, time_sale_dim ts,
property_dim pr, client_dim c
where fr.time_rent_id = tr.time_rent_id and fs.time_sale_id = ts.time_sale_id and
pr.property_id = fr.property_id and pr.property_id = fs.property_id and
c.person_id = fr.client_person and c.person_id = fs.client_person
and c.budget_range = 'High'
group by tr.time_rent_year,ts.time_sale_year
order by time_rent_year, time_sale_year;

--Report 9
--a.)What is the total rental fees and cumulative rental fees by property type in
--each year? (cumulative aggregate)

--b.)Explanation: This query is particularly useful in understanding the rental 
--properties trend among tenant by each year and to know the contribution 
--of rental fees in total for a year

--c.)SQL command
select tr.time_rent_year, pr.property_type, sum(fr.total_rental) as Total_Rental,
to_char(sum(sum(fr.total_rental)) over(order by tr.time_rent_year 
rows unbounded preceding), '9,999,999.99') 
as Cumulative_rental_fees
from monre_rent_fact_v1 fr, time_rent_dim tr, property_dim pr
where fr.time_rent_id = tr.time_rent_id and fr.property_id = pr.property_id
group by tr.time_rent_year, pr.property_type
order by time_rent_year;

--Report 10
--a.)What is the total rental fees and moving aggregate rental fees by property type in
--each month of the year? (moving aggregate)

--b.)Explanation: This query is particularly useful in understanding the rental 
--properties trend among tenant by each year and to know the contribution in average
--by months of a year

--c.)SQL command
select tr.time_rent_id, pr.property_type, sum(fr.total_rental) as Total_Rental,
to_char(avg(sum(fr.total_rental)) over(order by tr.time_rent_id 
rows 2 preceding), '9,999,999.99') 
as Moving_aggregate_3_monthly_rental_fees
from monre_rent_fact_v1 fr, time_rent_dim tr, property_dim pr
where fr.time_rent_id = tr.time_rent_id and fr.property_id = pr.property_id
group by tr.time_rent_id, pr.property_type
order by time_rent_id;

--Report 11
--a.)Show ranking of each property type based on the yearly total number of 
--sales and the ranking of each state based on the yearly total number of sales.

--b.)Explanation: this query is useful to management to analyse the company
--based on property type and state which it has been able to most actively market
--properties

--c.)SQL command
select t.time_sale_year, pr.property_type, s.state_name, 
count(f.total_number_of_sale) as Total_number_of_sales, 
rank()over (partition by pr.property_type order by count(f.total_number_of_sale)desc)
as rank_by_property_type,
rank()over (partition by s.state_name order by count(f.total_number_of_sale)desc)
as rank_by_state
from monre_sale_fact_v1 f, property_dim pr, time_sale_dim t, state_dim s,
postcode_dim po, address_dim a
where f.property_id = pr.property_id and f.time_sale_id = t.time_sale_id and
pr.address_id = a.address_id and a.postcode = po.postcode and
po.state_code = s.state_code
group by t.time_sale_year, pr.property_type, s.state_name;

--Report 12
--a.)Show ranking of each property scale on the yearly total number of 
--sales and the ranking of each suburb on the yearly total number of sales.

--b.)Explanation: this query is useful to management to analyse the company
--based on property scale and the suburb that it has been able to most actively market
--properties

--c.)SQL command
select t.time_sale_year, pr.property_scale, a.suburb, 
count(f.total_number_of_sale) as Total_number_of_sales, 
rank()over (partition by pr.property_scale order by count(f.total_number_of_sale)desc)
as rank_by_property_scale,
rank()over (partition by a.suburb order by count(f.total_number_of_sale)desc)
as rank_by_suburb
from monre_sale_fact_v1 f, property_dim pr, time_sale_dim t, address_dim a
where f.property_id = pr.property_id and f.time_sale_id = t.time_sale_id and
pr.address_id = a.address_id
group by t.time_sale_year, pr.property_scale, a.suburb;










