/*Task c2 Version 1 Level 2*/
 
 /*create table propety dimension*/
 
 drop table property_dim CASCADE CONSTRAINTS PURGE ;
 
 create table property_dim as select * from MONRE.property;
 
 /*add and update propert_dim with property_scale*/
 
 alter table property_dim add (property_scale varchar2(15));
 
 update property_dim set property_scale = 'Extra Small'
 where property_no_of_bedrooms <= 1;
 
 update property_dim set property_scale = 'Small'
 where property_no_of_bedrooms >= 2 and property_no_of_bedrooms <= 3;
 
 update property_dim set property_scale = 'Medium'
 where property_no_of_bedrooms >= 3 and property_no_of_bedrooms <= 6; 
 
 update property_dim set property_scale = 'Large'
 where property_no_of_bedrooms >= 6 and property_no_of_bedrooms <= 10; 
 
 update property_dim set property_scale = 'Extra Large'
 where property_no_of_bedrooms > 10;
 
 /*create table address dimension*/
 drop table address_dim CASCADE CONSTRAINTS PURGE ;
 
 create table address_dim as select * from monre.address;
 
 /*create table postcode dimension*/
 
 drop table postcode_dim CASCADE CONSTRAINTS PURGE ;
 
 create table postcode_dim as select * from MONRE.postcode;
 
  /*create table state dimension*/
 
 drop table state_dim CASCADE CONSTRAINTS PURGE ;
 
 create table state_dim as select * from MONRE.state;
 
 /*create table agent office dimension*/
 drop table office_dim CASCADE CONSTRAINTS PURGE ;
 
 create table office_dim as select * from MONRE.office;
 
 /*create table agent office bridge*/
 drop table agent_office_bridge CASCADE CONSTRAINTS PURGE ;
 
 create table agent_office_bridge as select a.person_id, o.office_name
 from MONRE.agent a, MONRE.office o, MONRE.agent_office ao
 where ao.person_id = a.person_id and o.office_id = ao.office_id;
 
 /*create table agent dimension*/
 drop table agent_dim CASCADE CONSTRAINTS PURGE ;
 
 create table agent_dim as select a.person_id, a.salary, 
 1.0 / count(o.office_name) as weightfactor,
 listagg(o.office_name, '_') within group(order by o.office_name) as officeNameList
 from MONRE.agent a, MONRE.office o, MONRE.agent_office ao
 where ao.person_id = a.person_id and o.office_id = ao.office_id
 group by a.person_id, a.salary;
 
 /*create table sale dimension*/
 drop table sale_dim CASCADE CONSTRAINTS PURGE ;
 
 create table sale_dim as select * from MONRE.sale;
 
 /*create table rent dimension*/
 drop table rent_dim CASCADE CONSTRAINTS PURGE ;
 
 create table rent_dim as select * from monre.rent;
 
 /*add and update rent dimension with rental_period*/
 alter table rent_dim add (rental_period varchar2(15));
 
 update rent_dim set rental_period ='Short' 
 where months_between(to_date(rent_end_date), to_date(rent_start_date)) < 6;
 
 update rent_dim set rental_period ='Medium' 
 where months_between(to_date(rent_end_date), to_date(rent_start_date)) >= 6 
 and months_between(to_date(rent_end_date), to_date(rent_start_date)) <= 12;
 
 update rent_dim set rental_period ='Long' 
 where months_between(to_date(rent_end_date), to_date(rent_start_date)) > 12;
 
 /*create table time dimension*/
 drop table time_rent_dim cascade CONSTRAINTS PURGE ;
 
 create table time_rent_dim as 
 select distinct to_char(rent_start_date,'YYYYMM') as time_rent_id,
 to_char(rent_start_date, 'Month') as time_rent_month,
 to_char(rent_start_date, 'YYYY') as time_rent_year
 from monre.rent;
 
/*create table time dimension*/
 drop table time_sale_dim cascade CONSTRAINTS PURGE ;
 
 create table time_sale_dim as 
 select distinct to_char(sale_date,'YYYYMM') as time_sale_id,
 to_char(sale_date, 'Month') as time_sale_month,
 to_char(sale_date, 'YYYY') as time_sale_year
 from monre.sale;
 
 /*create table season dimension*/
 DROP TABLE season_dim CASCADE CONSTRAINTS PURGE;

CREATE TABLE season_dim (
    season_id     VARCHAR2(10),
    season_desc   VARCHAR2(20),
    begin_date    DATE,
    end_date      DATE
);
 
 /*populate season dimension for Summer, Autumn, Winter, Spring*/

INSERT INTO season_dim VALUES (
    'S1',
    'Summer',
    TO_DATE('01-12', 'DD-MM'),
    TO_DATE('29-02', 'DD-MM')
);

INSERT INTO season_dim VALUES (
    'S2',
    'Autumn',
    TO_DATE('01-03', 'DD-MM'),
    TO_DATE('31-05', 'DD-MM')
);

INSERT INTO season_dim VALUES (
    'S3',
    'Winter',
    TO_DATE('01-06', 'DD-MM'),
    TO_DATE('31-08', 'DD-MM')
);

INSERT INTO season_dim VALUES (
    'S4',
    'Spring',
    TO_DATE('01-09', 'DD-MM'),
    TO_DATE('30-11', 'DD-MM')
);

/*create table client wish dimension*/
drop table client_wish_dim CASCADE CONSTRAINTS PURGE ;

create table client_wish_dim as select * from MONRE.client_wish;

/*create table person dimension*/
drop table person_dim CASCADE CONSTRAINTS PURGE ;

create table person_dim as select * from MONRE.person;

/*create table client dimension*/
drop table client_dim CASCADE CONSTRAINTS PURGE ;

create table client_dim as select * from MONRE.client;

/*add and update client dimension with budget_range*/
alter table client_dim add ( budget_range varchar2(15));

update client_dim set budget_range = 'Low'
where max_budget >= 0 and max_budget <= 1000;

update client_dim set budget_range = 'Medium'
where max_budget >= 1001 and max_budget <= 100000;

update client_dim set budget_range = 'High'
where max_budget >= 100001 and max_budget <= 1000000;


/*create table feature dimension*/
drop table feature_dim cascade constraints purge;

create table feature_dim as select * from MONRE.feature;

/*create table property feature dimesnion*/
drop table property_feature_dim CASCADE CONSTRAINTS PURGE;

create table property_feature_dim as select * from MONRE.property_feature;

/*create table visit dimension*/
drop table visit_dim CASCADE CONSTRAINTS PURGE;

create table visit_dim as 
select client_person_id, agent_person_id, property_id, duration, visit_date, 
to_char(visit_date, 'DY, MON, YYYY') as visit_date2
from MONRE.visit;

/*create table property advertisement slow changinging dimension type 2*/
drop table property_advert_SCD2 CASCADE CONSTRAINTS PURGE;

create table property_advert_SCD2 as 
select a.advert_id ||'_'|| rank()over(partition by a.advert_id 
order by to_date(p.property_date_added, 'DD/MM/YYYY')asc) as advert_id, 
pa.property_id, p.property_date_added as advertisemet_date,
case 
when p.property_date_added is null then 'N' else 'Y' end as CurrentFlag
from MONRE.advertisement a, MONRE.property_advert pa, MONRE.property p
where a.advert_id = pa.advert_id(+) and
pa.property_id = p.property_id(+);

/*create table MonRE_temp_fact_v1*/
drop table MonRE_temp_fact_v1 cascade CONSTRAINTS PURGE ;

create table MonRE_temp_fact_v1 as select pr.property_id, s.sale_id, 
a.salary, s.price sale_price, s.sale_date, to_char(s.sale_date,'YYYYMM') as time_sale_id,
a.person_id agent_person, 
c.person_id client_person, v.property_id visit_property, v.visit_date 
from monre.sale s join monre.property pr on pr.property_id = s.property_id  
left join MONRE.visit v on pr.property_id = v.property_id
left join MONRE.agent a on s.agent_person_id = a.person_id
left join MONRE.client c on s.client_person_id = c.person_id;

/*add acolumn in the MonRE_temp_fact_v1 to store season id*/
alter table MonRE_temp_fact_v1 add (season_id varchar2(10));

update MonRE_temp_fact_v1 set season_id = 'S1' where to_char(visit_date, 'MM') = '12'
or to_char(visit_date, 'MM') = '01' or to_char(visit_date, 'MM') = '02';

update MonRE_temp_fact_v1 set season_id = 'S2' where to_char(visit_date, 'MM') = '03'
or to_char(visit_date, 'MM') = '04' or to_char(visit_date, 'MM') = '05';

update MonRE_temp_fact_v1 set season_id = 'S3' where to_char(visit_date, 'MM') = '06'
or to_char(visit_date, 'MM') = '07' or to_char(visit_date, 'MM') = '08';

update MonRE_temp_fact_v1 set season_id = 'S4' where to_char(visit_date, 'MM') = '09'
or to_char(visit_date, 'MM') = '10' or to_char(visit_date, 'MM') = '11';

/*create table MonRE_temp_fact_v2*/
drop table MonRE_temp_fact_v2 cascade CONSTRAINTS PURGE;

create table MonRE_temp_fact_v2 as select pr.property_id, r.rent_id,
r.rent_start_date, r.rent_end_date, to_char(r.rent_start_date,'YYYYMM') as time_rent_id,
r.price rent_price, a.salary,
a.person_id agent_person, c.person_id client_person, v.property_id visit_property, v.visit_date 
from monre.rent r join monre.property pr on pr.property_id = r.property_id 
left join MONRE.visit v on pr.property_id = v.property_id
left join MONRE.agent a on r.agent_person_id = a.person_id
left join MONRE.client c on r.client_person_id = c.person_id;

/*add acolumn in the MonRE_temp_fact_v2 to store season id*/
alter table MonRE_temp_fact_v2 add (season_id varchar2(10));

update MonRE_temp_fact_v2 set season_id = 'S1' where to_char(visit_date, 'MM') = '12'
or to_char(visit_date, 'MM') = '01' or to_char(visit_date, 'MM') = '02';

update MonRE_temp_fact_v2 set season_id = 'S2' where to_char(visit_date, 'MM') = '03'
or to_char(visit_date, 'MM') = '04' or to_char(visit_date, 'MM') = '05';

update MonRE_temp_fact_v2 set season_id = 'S3' where to_char(visit_date, 'MM') = '06'
or to_char(visit_date, 'MM') = '07' or to_char(visit_date, 'MM') = '08';

update MonRE_temp_fact_v2 set season_id = 'S4' where to_char(visit_date, 'MM') = '09'
or to_char(visit_date, 'MM') = '10' or to_char(visit_date, 'MM') = '11';

/*create table monre_fact_v1 */
drop table monre_sale_fact_v1 cascade constraints purge;

create table monre_sale_fact_v1 as select distinct t1.property_id, t1.sale_id,
t1.season_id, t1.agent_person, t1.client_person, t1.time_sale_id, 
count(distinct t1.sale_date) as total_number_of_sale,
count(distinct t1.agent_person) as total_number_of_agents,
count(distinct t1.client_person) as total_number_of_clients,
count(distinct t1.property_id) as total_number_of_properties,
count(t1.visit_property) as total_number_of_property_visit,
sum(distinct t1.sale_price) as total_sales,
sum(distinct t1.salary) as total_agent_earning
from monre_temp_fact_v1 t1 
group by t1.property_id, t1.sale_id,t1.season_id, t1.agent_person, 
t1.client_person, t1.time_sale_id;

/*create table monre_rent_fact_v1*/
drop table monre_rent_fact_v1 cascade constraints purge;

create table monre_rent_fact_v1 as select distinct t2.property_id, t2.rent_id,
t2.season_id, t2.agent_person, t2.client_person, t2.time_rent_id,
count(distinct t2.rent_start_date) as total_number_of_rent,
count(distinct t2.agent_person) as total_number_of_agents,
count(distinct t2.client_person) as total_number_of_clients,
count(distinct t2.property_id) as total_number_of_properties,
count(t2.visit_property) as total_number_of_property_visit,
sum(distinct t2.rent_price) as total_rental,
sum(distinct t2.salary) as total_agent_earning
from monre_temp_fact_v2 t2
group by t2.property_id, t2.rent_id, t2.season_id, t2.agent_person, 
t2.client_person, t2.time_rent_id;

/*---------------------------------------------------------------------------------------------*/

/*Task c2 - Star Schema Version 2 *Level 0: No Aggregation* */

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