-- retrieve first 10 rows of dataset
select *
from corona
limit 10;

-- update the data structure and type for our date_recorded column
UPDATE corona
SET date_recorded = STR_TO_DATE(date_recorded, '%d-%m-%Y')
WHERE STR_TO_DATE(date_recorded, '%d-%m-%Y') IS NOT NULL;

ALTER TABLE corona MODIFY date_recorded DATE;

-- QUESTION 1 & 2 checking for null values

select *
from corona
where province is null or country_region is null or latitude is null or longitude is null or 
	date_recorded is null or confirmed is null or deaths is null or recovered is null;

-- QUESTION 3 count number of rows in our dataset

select
	count(*)
from corona;

-- QUESTION 4 get earliest and latest dates in our dataset
select 
	min(date_recorded)
from corona;

select 
	max(date_recorded)
from corona;

-- confirm our date results above
select *
from corona
order by date_recorded asc
limit 10;

-- QUESTION 5 count number of months in our dataset

select
	count(distinct concat(year(date_recorded), '-', month(date_recorded))) as unique_months
from corona;

-- QUESTION 6 get average of confirmed, deaths and recovered for each of the 18 months

select
	distinct concat(year(date_recorded), '-', month(date_recorded)) as month_year,
	round(avg(confirmed), 1) confirmed_avg,
    round(avg(deaths), 1) as deaths_avg,
    round(avg(recovered), 1) as recovered_avg
from corona
group by(concat(year(date_recorded), '-', month(date_recorded)));

-- get averages for each of the 18 months for the countries that had the highest totals
select
	distinct concat(year(date_recorded), '-', month(date_recorded)) as month_year,
    country_region,
	round(avg(confirmed), 1) confirmed_avg,
    round(avg(deaths), 1) as deaths_avg,
    round(avg(recovered), 1) as recovered_avg
from corona
where country_region in( "US","India", "Brazil")
group by(concat(year(date_recorded), '-', month(date_recorded))), country_region;

-- QUESTION 7 get the mode for each of the 18 months

with mode_rank as(
	select 
        concat(year(date_recorded), '-', month(date_recorded)) as date,
        confirmed,
        deaths,
        recovered,
        dense_rank() over (partition by concat(year(date_recorded), '-', month(date_recorded)) order by count(*) desc) as rn_confirmed,
        dense_rank() over (partition by concat(year(date_recorded), '-', month(date_recorded)) order by count(*) desc) as rn_deaths,
        dense_rank() over (partition by concat(year(date_recorded), '-', month(date_recorded)) order by count(*) desc) as rn_recovered
    from corona
    group by 
        date,
        confirmed,
        deaths,
        recovered
)
select 
    date,
    confirmed as confirmed_mode,
    deaths as deaths_mode,
    recovered as recovered_mode
from 
    mode_rank
where 
    rn_confirmed = 1
    and rn_deaths = 1
    and rn_recovered = 1;

-- QUESTION 8 get min values present in 2020 and 2021

select
	year(date_recorded) as yr,
    min(confirmed),
    min(deaths),
    min(confirmed)
from corona
group by yr
order by yr asc;

-- QUESTION 9 get max values for 2020 and 2021

select
	year(date_recorded) as yr,
    max(confirmed),
    max(deaths),
    max(recovered)
from corona
group by yr
order by yr asc;

-- QUESTION 10 get totals for each month

select
	concat(year(date_recorded), '-', month(date_recorded)) as date,
    sum(confirmed) as confirmed_total,
    sum(deaths) as deaths_total,
    sum(recovered) as recovered_total
from corona
group by date;

-- QUESTION 11 get overall total, avg, variance and stddev of confirmed cases

select
	sum(confirmed) as confirmed_total,
    avg(confirmed) as confirmed_avg,
    stddev(confirmed) as confirmed_dev,
    variance(confirmed) as confirmed_var
from corona;

-- QUESTION 12 get overall total, avg, variance and stddev of deaths

select
	sum(deaths) as deaths_total,
    avg(deaths) as deaths_avg,
    stddev(deaths) as deaths_dev,
    variance(deaths) as deaths_var
from corona;

-- QUESTION 13 get overall total, avg, variance and stddev of recovered

select
	sum(recovered) as recovered_total,
    avg(recovered) as recovered_avg,
    stddev(recovered) as recovered_dev,
    variance(recovered) as recovered_var
from corona;

-- QUESTION 14 retrieve country with the highest total of confirmed cases

select
	country_region,
	sum(confirmed) as confirmed_total
from corona
group by country_region
order by confirmed_total desc
limit 1;

-- QUESTION 15 get country with the lowest deaths

select
	country_region,
	sum(deaths) as deaths_total
from corona
group by country_region
order by deaths_total asc
limit 1;

-- QUESTION 16 retrieve top 5 countries with the highest recovery totals

select
	country_region,
	sum(recovered) as recovered_total
from corona
group by country_region
order by recovered_total desc
limit 5;

-- count number of countries present in dataset
select count(distinct country_region)
from corona;

-- get number of records per country
select country_region,
	count(*) as region_record_count
from corona
group by country_region
order by region_record_count desc;

-- get overall average of confirmed cases, deaths and recovered per day.
with daily_avg as(
	select
		date_recorded,
		avg(confirmed) as avg_confirmed,
		avg(deaths) as avg_deaths,
		avg(recovered) as avg_recovered
	from corona
	group by date_recorded)
select 
	avg(avg_confirmed),
    avg(avg_deaths),
    avg(avg_recovered)
from daily_avg;

-- get total of confirmed, death and recovered by year.
select
	year(date_recorded),
	sum(confirmed) as total_confirmed,
    sum(deaths) as total_deaths,
    sum(recovered) as total_recovered
from corona
group by year(date_recorded);

-- get total of confirmed, death and recovered by country displayed in ascending order
select
	country_region,
	sum(confirmed),
    sum(deaths),
    sum(recovered)
from corona
group by country_region
order by sum(confirmed) asc;