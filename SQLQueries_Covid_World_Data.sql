select location,date,total_cases,new_cases,total_deaths,population
from portfolio_project..CovidDeaths 
order by 1,2;


--with relevant_table as
--(
--select location,date,total_cases,new_cases,total_deaths,population
--from portfolio_project..CovidDeaths
--)
--select location,relevant_table.total_cases,max(relevant_table.total_cases)
--from relevant_table
--group by location;

--Death Percentage by day
select location,date,total_cases,total_deaths, (cast(total_deaths as int)/total_cases)*100 as deathpct
from portfolio_project..CovidDeaths 
where location like 'India'
order by location,date asc


--Infection rates ranked from highest to lowest

with ipct as 
(
select location,date,population,total_cases, total_cases/population*100 as infectionpct
from portfolio_project..CovidDeaths
)
select location, population, max(infectionpct) as ipctmax
from ipct 
group by location,population
order by ipctmax desc

--Analysis of death percentage per total cases by country:

with dpct as 
(
select location,date,total_cases,total_deaths, (cast(total_deaths as int)/total_cases)*100 as deathpct
from portfolio_project..CovidDeaths
where continent is not null
)
select location, max(cast(total_deaths as int)) as td, max(deathpct) as dpctmax
from dpct 
group by location
order by dpctmax desc

-- Total deaths in all countries arranged by continents

with continent_wise_deaths as 
(
select continent,location, max(cast(total_deaths as int)) as td
from portfolio_project..CovidDeaths
where continent is not null
group by continent,location
)
select continent,sum(td) as totalDeaths
from continent_wise_deaths
group by continent
order by totalDeaths desc

select location, max(cast(total_deaths as int)) as td
from portfolio_project..CovidDeaths
where continent is null
group by location
order by td desc

select continent, Max(cast(total_deaths as int)) as maxdeath
from portfolio_project..CovidDeaths
where continent is not null
group by continent
order by maxdeath desc

--select date,sum(new_cases) as totalCases,sum(cast(new_deaths as int)) as totalDeaths, 
--       (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpct
--from portfolio_project..CovidDeaths
--where continent is not null
--group by date
--order by 1


-- vaccinations analysis

--vaccination rates per country
with VaxPercentage as
(
select cas.continent,cas.location,cas.date,cas.people_vaccinated,dea.population
from portfolio_project..CovidCases cas
join portfolio_project..CovidDeaths dea
on cas.location=dea.location
and cas.date = dea.date
where cas.continent is not null
)
select continent,location, Max(cast(people_vaccinated as bigint)), population, 
       (Max(cast(people_vaccinated as bigint))/population) * 100
from VaxPercentage
group by continent,location,population
order by 1

-- rolling count of vaccinations with each succession
with VaxPercentage as
(
select cas.continent,cas.location,cas.date,dea.population,cas.new_vaccinations,
       sum(cast(cas.new_vaccinations as bigint)) over (partition by cas.location order by cas.location,cas.date) 
	   as rollingVaxColumn
from portfolio_project..CovidCases cas
join portfolio_project..CovidDeaths dea
on cas.location=dea.location
and cas.date = dea.date
where cas.continent is not null
)
select *,(rollingVaxColumn/population)*100 as pct
from VaxPercentage
order by 2,3



