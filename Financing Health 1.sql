-- DATA ASSESSMENT
select *
from annual_expenditure;
select *
from country_life_expectancy;
select *
from regional_life_expectancy;

-- DATA ANALYSIS
-- Average national expenditures over 10 years (2010 to 2019)
-- National
select *, round(avg(CHE_per_capita) over (partition by entity),2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and country_code is not null;
-- Regional
select entity,year, CHE_per_capita, round(avg(CHE_per_capita) over (partition by entity),2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and entity in ('Africa', 'Americas', 'Europe', 'Western Pacific', 'Eastern Mediterranean');

-- Top 5 healthcare expenditures as at 2019
select *
from annual_expenditure
where year =2019
and country_code is not null
order by CHE_per_capita desc
limit 5;

-- Bottom 5 healthcare expenditures as at 2019
select *
from annual_expenditure
where year =2019
and country_code is not null
order by CHE_per_capita 
limit 5;

-- National Rankings 2019
select entity, CHE_per_capita,
rank() over (order by CHE_per_capita desc) as national_rank
from annual_expenditure
where country_code is not null
and year =2019;

-- Regional ranking  2019 
select entity, CHE_per_capita,
rank() over (order by CHE_per_capita desc) as regional_rank
from annual_expenditure
where entity in ('Africa', 'Americas', 'Europe', 'Western Pacific', 'Eastern Mediterranean')
and year =2019;

-- National ranking of average CHE expenditure over 10 years
with avg_national_che as 
(select *, round(avg(CHE_per_capita) over (partition by entity), 2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and country_code is not null)

select entity, CHE_per_capita, avg_CHE, 
rank() over ( order by avg_CHE desc) as avg_che_national_rank
from avg_national_che
where country_code is not null
and year =2019;

-- Regional ranking of average CHE expenditure over 10 years
with avg_regional_che as 
(select *, round(avg(CHE_per_capita) over (partition by entity),2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and country_code is null)

select entity, CHE_per_capita, avg_CHE , 
rank() over ( order by avg_CHE desc) as avg_che_regional_rank
from avg_regional_che
where entity in ('Africa', 'Americas', 'Europe', 'Western Pacific', 'Eastern Mediterranean')
and year =2019;

-- LIFE EXPECTANCY
-- life expectancy in countries over 10 years
-- National
select Country,
 floor((2019_f+2015_f+2010_f)/3)as avg_female_life_exp,
 floor((2019_m+2015_m+2010_m)/3) as avg_male_life_exp
from country_life_expectancy;
-- Regional
select Regions,
 floor((2019_f+2015_f+2010_f)/3)as avg_female_life_exp,
 floor((2019_m+2015_m+2010_m)/3) as avg_male_life_exp
from regional_life_expectancy;

-- NATIONAL LIFE EXPECTANCIES VS HEALTHCARE EXPENDITURE
-- 2010
select a.entity, a.country_code, a.CHE_per_capita, 
floor(l.2010_m) as male_life_exp,
floor( l.2010_f) as female_life_exp
from annual_expenditure as a
left join country_life_expectancy as l
on a.entity = l.Country
where year = 2010
and country_code is not null;

-- 2019
select a.entity, a.country_code, a.CHE_per_capita, 
floor(l.2019_m) as male_life_exp, 
floor(l.2019_f) as female_life_exp
from annual_expenditure as a
left join country_life_expectancy as l
on a.entity = l.Country
where year = 2019
and country_code is not null;

-- REGIONAL LIFE EXPECTANCIES VS HEALTHCARE
-- 2010
select a.entity, a.CHE_per_capita, 
floor(l.2010_m) as male_life_exp, 
floor(l.2010_f) as female_life_exp
from annual_expenditure as a
left join regional_life_expectancy as l
on a.entity = l.Regions
where year = 2010
and country_code is null
and entity in ('Africa', 'Americas', 'Europe', 'Western Pacific', 'Eastern Mediterranean');

-- 2019
select a.entity, a.CHE_per_capita,
floor(l.2019_m) as male_life_exp,
floor(l.2019_f) as female_life_exp
from annual_expenditure as a
left join regional_life_expectancy as l
on a.entity = l.Regions
where year = 2019
and country_code is null
and entity in ('Africa', 'Americas', 'Europe', 'Western Pacific', 'Eastern Mediterranean');

-- CREATING VIEW FOR VISUALIZATIONS
-- (1)  average national che
create view average_national_CHE as
select *, round(avg(CHE_per_capita) over (partition by entity),2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and country_code is not null;

-- (2) average regional che
create view average_regional_che as
select entity,year, CHE_per_capita, round(avg(CHE_per_capita) over (partition by entity),2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and entity in ('Africa', 'Americas', 'Europe', 'Western Pacific', 'Eastern Mediterranean');

-- (3) National Rankings
create view national_rankings as
with avg_national_che as 
(select *, round(avg(CHE_per_capita) over (partition by entity), 2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and country_code is not null)

select entity, CHE_per_capita, avg_CHE, 
rank() over ( order by avg_CHE desc) as avg_che_national_rank
from avg_national_che
where country_code is not null
and year =2019;

-- (4) Regional Rankings
create view regional_rankings as
with avg_regional_che as 
(select *, round(avg(CHE_per_capita) over (partition by entity),2) as avg_CHE
from annual_expenditure
where year between 2010 and 2019
and country_code is null)

select entity, CHE_per_capita, avg_CHE , 
rank() over ( order by avg_CHE desc) as avg_che_regional_rank
from avg_regional_che
where entity in ('Africa', 'Americas', 'Europe', 'Western Pacific', 'Eastern Mediterranean')
and year =2019;

-- (5) Average life expectancy
create view avg_life_exp as
select Country,
 floor((2019_f+2015_f+2010_f)/3)as avg_female_life_exp,
 floor((2019_m+2015_m+2010_m)/3) as avg_male_life_exp
from country_life_expectancy;