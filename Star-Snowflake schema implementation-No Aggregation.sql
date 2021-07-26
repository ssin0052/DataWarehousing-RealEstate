 /*Task 2 - Star Schema Version 2 *Level 0: No Aggregation* */
 /*create table property dimension*/
drop table property_dim_v2 CASCADE CONSTRAINTS PURGE;
 
create table property_dim_v2 as select * from MONRE.property;

 /*create table address dimension*/
 drop table address_dim_v2 CASCADE CONSTRAINTS PURGE;
 
 create table address_dim_v2 as select * from monre.address; 
 
  /*create table postcode dimension*/
 
 drop table postcode_dim_v2 CASCADE CONSTRAINTS PURGE;
 
 create table postcode_dim_v2 as select * from MONRE.postcode;
 
  /*create table state dimension*/
 
 drop table state_dim_v2 CASCADE CONSTRAINTS PURGE;
 
 create table state_dim_v2 as select * from MONRE.state;
 
 /*create table agent office dimension*/
 drop table office_dim_v2 CASCADE CONSTRAINTS PURGE;
 
 create table office_dim_v2 as select * from MONRE.office;
 
/*create table agent dimension*/
 drop table agent_dim_v2 CASCADE CONSTRAINTS PURGE;
 
 create table agent_dim_v2 as select * from MONRE.agent;
 
  /*create table agent office bridge*/
 drop table agent_office_bridge_v2 CASCADE CONSTRAINTS PURGE;
 
create table agent_office_bridge_v2 as select a.person_id, o.office_id
 from MONRE.agent a, MONRE.office o, MONRE.agent_office ao
 where ao.person_id = a.person_id and o.office_id = ao.office_id;
 
 /*create table sale dimension*/
 drop table sale_dim_v2 CASCADE CONSTRAINTS PURGE;
 
 create table sale_dim_v2 as select * from MONRE.sale;
 
  /*create table rent dimension*/
 drop table rent_dim_v2 CASCADE CONSTRAINTS PURGE;
 
 create table rent_dim_v2 as select * from monre.rent;
 
  /*create table client wish dimension*/
drop table client_wish_dim_v2 CASCADE CONSTRAINTS PURGE;

create table client_wish_dim_v2 as select * from MONRE.client_wish;
 
 /*create table person dimension*/
drop table person_dim_v2 CASCADE CONSTRAINTS PURGE;

create table person_dim_v2 as select * from MONRE.person;

/*create table client dimension*/
drop table client_dim_v2 CASCADE CONSTRAINTS PURGE;

create table client_dim_v2 as select * from MONRE.client;

/*create table feature dimension*/
drop table feature_dim_v2 CASCADE CONSTRAINTS PURGE;

create table feature_dim_v2 as select * from MONRE.feature;

/*create table property feature dimesnion*/
drop table property_feature_dim_v2 CASCADE CONSTRAINTS PURGE;

create table property_feature_dim_v2 as select * from MONRE.property_feature;

/*create table visit dimension*/
drop table visit_dim_v2 CASCADE CONSTRAINTS PURGE;

create table visit_dim_v2 as select * from MONRE.visit;

/*create table advertisement dimension*/
drop table advertisement_dim_v2 CASCADE CONSTRAINTS PURGE;

create table advertisement_dim_v2 as select * from MONRE.advertisement;

/*create table property advertisement dimension*/
drop table property_advert_dim_v2 CASCADE CONSTRAINTS PURGE;

create table property_advert_dim_v2 as select pa.property_id, pa.advert_id, pa.agent_person_id, pa.cost 
from MONRE.property_advert pa, MONRE.advertisement a
where pa.advert_id = a.advert_id;

/*create table MonRE_rent_fact_v2*/
drop table MonRE_rent_fact_v2 cascade constraints purge;

create table MonRE_rent_fact_v2 as select distinct
r.rent_id, p.property_id, a.person_id agent,  c.person_id client, 
v.visit_date, r.rent_start_date, r.rent_end_date, r.price,
count(distinct r.rent_start_date) as total_number_of_rent,
count(distinct a.person_id) as total_number_of_agents,
count(distinct c.person_id) as total_number_of_clients,
count(distinct p.property_id) as total_number_of_properties,
count(distinct v.property_id) as total_number_of_property_visit,
sum(distinct r.price) as total_rental,
sum(distinct a.salary) as total_agent_earning
from monre.rent r join monre.property p on r.property_id = p.property_id
left join monre.visit v on p.property_id = v.property_id
left join monre.agent a on r.agent_person_id = a.person_id
left join monre.client c on r.client_person_id = c.person_id
group by r.rent_id, p.property_id, a.person_id, a.salary, 
c.person_id, v.property_id, v.visit_date,
 r.rent_start_date, r.rent_end_date, r.price;

/*create table MonRE_sale_fact_v2*/
drop table MonRE_sale_fact_v2 cascade constraints purge;

create table MonRE_sale_fact_v2 as select distinct
s.sale_id, p.property_id, a.person_id agent, c.person_id client,
v.visit_date, s.sale_date, s.price sale_price,
count(distinct s.sale_date) as total_number_of_sale,
count(distinct a.person_id) as total_number_of_agents,
count(distinct c.person_id) as total_number_of_clients,
count(distinct p.property_id) as total_number_of_properties,
count(v.property_id) as total_number_of_property_visit,
sum(distinct s.price) as total_sales,
sum(distinct a.salary) as total_agent_earning
from monre.sale s join monre.property p on s.property_id = p.property_id
left join monre.visit v on p.property_id = v.property_id
left join monre.agent a on s.agent_person_id = a.person_id
left join monre.client c on s.client_person_id = c.person_id
group by s.sale_id, p.property_id, a.person_id, c.person_id,
v.visit_date, s.sale_date, s.price;









 

 