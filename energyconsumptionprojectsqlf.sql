CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
     energy_type VARCHAR(50),
    year INT,
    emission decimal(20,10),
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);
SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);
SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(200),
    energy VARCHAR(200),
    year INT,
    produces decimal(20,10)
   -- FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
	consumption decimal(20,10),
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

-- General & Comparative Analysis
-- 1Q.What is the total emission per country for the most recent year available?
select country,sum(emission),year from emission_3 as e
where year=(select max(year) from emission_3)
group by country,year;
-- if  is avaliable year is not max for few countries then
select country,sum(emission),year from emission_3 as e
where year=(select max(year) from emission_3 f where e.country=f.country)
group by country,year;

-- 2Q.What are the top 5 countries by GDP in the most recent year?
select country,sum(value) as sumvalue from gdp_3 g
where year=(select max(year) from gdp_3 f where g.country=f.country)
group  by country
order by sumvalue desc
limit 5;

-- 3Q.Compare energy production and consumption by country and year. 
select p.country as country,sum(p.produces) as sumproduction,sum(c.consumption) as sumconsumption,p.year as years from production p
left join 
(select country ,consumption from consumption) as c
on p.country=c.country
group by country,years;
-- 892 rows
-- obsevarions most countries not doing more production but energy uses is more ,some produce more enery and consumption is less
-- if we observe below table ,we get 686 rows nearly 80% countries not doing production but consume energy more
select p.country as country,sum(p.produces) as sumproduction,sum(c.consumption) as sumconsumption,p.year as years from production p
left join 
(select country ,consumption from consumption) as c
on p.country=c.country
group by country,years
having sumproduction<sumconsumption;
-- if we observe below table produce more enery and consumption is less nearly 20% countries
select p.country as country,sum(p.produces) as sumproduction,sum(c.consumption) as sumconsumption,p.year as years from production p
left join 
(select country ,consumption from consumption) as c
on p.country=c.country
group by country,years
having sumproduction>sumconsumption;

-- 4Q.Which energy types contribute most to emissions across all countries?
select * from emission_3;
select energy_type,sum(emission) as sumemission from emission_3
group by energy_type
order by sumemission desc
limit 1;
-- observation co2 emissions energy type cause more emissions


-- Trend Analysis Over Time
-- 5Q.How have global emissions changed year over year?
select year,sum(emission) as sumemission from emission_3
group by year
order by sumemission desc;
-- observation:year by year emission are increased by 2% from 2020 to 2023

-- 6Q.What is the trend in GDP for each country over the given years?
select g1.country,g1.year,g1.totalgdp,
round(((g2.totalgdp-g1.totalgdp)/g1.totalgdp)*100,2) as yearofgrowth
from (select country,year,sum(value) as totalgdp from gdp_3 group by country,year) as g1
left join
(select country,year,sum(value) as totalgdp from gdp_3 group by country,year) as g2
on g1.country=g2.country and g2.year=g1.year+1
order by country,year;
-- observation:the trend is most of country gdp growth 3-5% per year

-- 7Q.How has population growth affected total emissions in each country?
select  e.country,e.year,sum(p.value),sum(e.emission) from emission_3 as e
left join
(select countries,year,value from population) as p
on
e.country=p.countries and e.year=p.year
group by e.country,e.year
order by sum(p.value),sum(e.emission) desc;

select * from population;
select * from emission_3;

-- 8Q.Has energy consumption increased or decreased over the years for major economies?
select year,sum(emission) from emission_3 
group by year;
-- observation:enery consumption increased by 2% every year

-- 9Q.What is the average yearly change in emissions per capita for each country?
select country,year,avg(per_capita_emission)  from emission_3
group by country,year;
-- observation: no change in per capita for each country


-- Ratio & Per Capita Analysis
-- 10Q.What is the emission-to-GDP ratio for each country by year?
select e.country,e.year,round(sum(e.emission)/sum(g.value),2) from emission_3 e
join
(select country,year,value from gdp_3) as g
on g.country=e.country and e.year=g.year
group by e.country,e.year;
select * from gdp_3;

-- 11Q.What is the energy consumption per capita for each country over the last decade?
select p.countries,sum(c.consumption)/sum(p.value) as energy_consumption_per_capita from population p
join
(select year,country,consumption from consumption)c
on
p.countries=c.country
group by p.countries;

select * from consumption;
select * from population;

-- 12Q.How does energy production per capita vary across countries?
select p.countries,sum(c.produces)/sum(p.value) as energy_consumption_per_capita from population p
join
(select year,country,produces from production)c
on
p.countries=c.country
group by p.countries;

select * from production;
select * from population;

-- 13Q.Which countries have the highest energy consumption relative to GDP?

select c.country,c.year,sum(c.consumption)/sum(g.value) as hec_countries from consumption c
join
(select country,year,value from gdp_3)g
on
c.country=g.country and c.year=g.year
group by c.country,c.year
order by hec_countries desc ;

select * from consumption;
select * from gdp_3;
-- 14Q.What is the correlation between GDP growth and energy production growth?
select p.year,p.country,sum(p.produces) ,sum(g.value)from production p
join
(select country,year,value from gdp_3) as g
on g.country=p.country and p.year=g.year
group by  p.year,p.country;

WITH country_data AS (
    SELECT 
        p.country,
        p.year,
        SUM(p.produces) AS total_production,
        SUM(g.value) AS total_gdp
    FROM production p
    JOIN gdp_3 g
        ON g.country = p.country AND g.year = p.year
    GROUP BY p.country, p.year
),
growth AS (
    SELECT
        c1.country,
        c1.year,
        c1.total_production,
        c1.total_gdp,
        ROUND((c1.total_production - c2.total_production)/c2.total_production * 100, 2) AS energy_growth_pct,
        ROUND((c1.total_gdp - c2.total_gdp)/c2.total_gdp * 100, 2) AS gdp_growth_pct
    FROM country_data c1
    JOIN country_data c2
        ON c1.country = c2.country
       AND c1.year = c2.year + 1
),
correlation AS (
    SELECT 
        country,
        SUM(energy_growth_pct * gdp_growth_pct) /
        (SQRT(SUM(energy_growth_pct * energy_growth_pct)) * 
         SQRT(SUM(gdp_growth_pct * gdp_growth_pct))) AS corr
    FROM growth
    GROUP BY country
)
SELECT *
FROM correlation
ORDER BY corr DESC;
-- observation:correlation is postive then GDP growth is strongly tied to energy production growth. 


--  Global Comparisons
-- 15Q.What are the top 10 countries by population and how do their emissions compare?

select  p.countries,p.value as population,sum(e.emission),p.year from population p
left join (select country,year,emission from emission_3) e
on e.country=p.countries and e.year=p.year
where p.year=2023 -- population lastest 2024 but emission avaliable only for 2023
group by p.countries,population -- in emission given same contries mutlipes times for same so iam sumimg the emission by grouping
order by population desc
limit 10;
-- observation : china is top emission and top population(1.4 b)(industries are more then emission is more not by population)
-- india(1.4b),china,usa population in descending order and economically gdp growing so  emission is affected by population growth
-- in usa population less compare to india and china but huge emission is more due to industries (usa emission:9k qbtu)
-- in china population sightly less compare to india but more emission(china:24k qbtu,india:5.5k qbtu)
-- russia population(14m) only less but emission is 3k qbtu)
select * from emission_3;

-- 16q.Which countries have improved (reduced) their per capita emissions the most over the last decade?
-- data is not sufficient, every country had same percapita emission in emission_3 table ,so we cant comment on  this

-- 17Q.What is the global share (%) of emissions by country?
select g.country,round((sum(g.emission)/max(d.totalemission))*100,2) as globalshareper from emission_3 as g
cross join
(select sum(emission) as totalemission from emission_3) as d
group by g.country
order by globalshareper desc;
select * from population;
-- 18q.What is the global average GDP, emission, and population by year?
select p.year,avg(p.value) as avgvaluepopulation,g.avgvaluegdp,e.avgvaluemission from population p
join
(select year,avg(value) as avgvaluegdp from gdp_3 group by year) g
on g.year=p.year
join
(select year,avg(emission) as avgvaluemission from emission_3 group by year) e
on p.year=e.year
group by p.year;


