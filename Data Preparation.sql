set echo on
spool task_1_output.doc;
/*-----------------------------------------------------------------------------------*/
--Due to the limitation in the space, monre database was not able to imported 
--to account while also having dimension and fact table. Hence data cleaning is done from
--the dimension and fact table.

--Version-1 (level 2)

--Error 1-Duplicate entry in the rent_dim
--Data before 
select count(*) as duplicate_records, property_id from rent_dim
group by property_id
having count(property_id) >1;

select* from rent_dim
where property_id = '5741';

--cleaning
delete from rent_dim where property_id = '5741' and price = 330;
commit;

--Data after
select count(*) as duplicate_records, property_id from rent_dim
group by property_id
having count(property_id) >1;

select* from rent_dim
where property_id = '5741';

--Error 2- Rent end date precedes rent start date
--Data before
select * from rent_dim
where rent_end_date < rent_start_date;

--Cleaning
update rent_dim
set rent_start_date = to_date('01/06/2019', 'DD/MM/YYYY'),
rent_end_date = to_date('31/12/2021', 'DD/MM/YYYY')
where rent_id = '3284' and property_id = '5741';
commit;

--Data after
select * from rent_dim
where rent_end_date < rent_start_date;

--Error 3- repeating entry of property 
--data before
select count(*) as duplicate_records, property_id 
from property_dim
group by property_id
having count(property_id) > 1;

select* from property_dim
where property_id = '6177' or property_id = '6179';

--cleaning
delete from property_dim where property_id = '6177' or property_id = '6179';
insert into property_dim values ('6177', to_date('25/11/2019', 'DD/MM/YYYY'), '6177',	
'Apartment / Unit / Flat',	'2',	'2',	'2', '', 'DUE TO FEDERAL GOVERNMENT 
RESTRICTIONS only one-on-one inspections are permitted at this time. It is imperative 
you MUST register for an inspection and we ask that if you cannot attend a booked 
inspection you call to cancel as soon as possible. AN AGENT WILL NOT BE PRESENT 
IF YOU DO NOT REGISTER. Your consideration and co-operation during these times is 
truly appreciated. Located in the highly', 'Small');
insert into property_dim values('6179',	to_date('19/01/2020','DD/MM/YYYY'),	'6179',	
'Apartment / Unit / Flat',	'1',	'1',	'1', '', 'Designer first floor apartment in 
desirable Carnegie location. Featuring open plan living with air conditioning 
opening to private balcony. Kitchen with SMEG appliances including dishwasher 
and gas cooking. Great sized bedroom. Sparkling bathroom and separate Euro Laundry.
Remote undercover secure basement parking and storage cage.Located only moments 
from shops, cafes and transport. You wont', 'Extra Small');
commit;

--data after
select count(*) as duplicate_records, property_id 
from property_dim
group by property_id
having count(property_id) > 1;

--Error 4- Invalid date for visit_date of a visit in visit_dim
--Data before
select * from visit_dim
where property_id = '5741'
order by visit_date desc;

--cleaning
update visit_dim set
visit_date = to_date('31/12/2019', 'DD/MM/YYYY')
where client_person_id = '6000' and agent_person_id = '6001' and 
property_id = '5741';

--Data after
select * from visit_dim
where property_id = '5741'
order by visit_date desc;

--Error 5--Null value in state_dim
--data before
Select * from monre.state;

--cleaning
delete from state_dim where state_code = '';
commit;

--data after
Select * from monre.state;

set echo off











