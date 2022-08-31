Select *
from Covid_Project..CovidDeaths1
where continent is not null
order by 3,4


--Select *
--from Covid_Project..CovidVaccinations11
--order by 3,4 


--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from Covid_Project..CovidDeaths1
order by 1,2


--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage from Covid_Project..CovidDeaths1 
where location like '%indi%' and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as percent_population_infected
from Covid_Project..CovidDeaths1 
--where location like '%ndia%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as 
percent_population_infected
from Covid_Project..CovidDeaths1 
--where location like '%ndia%'
group by location, population
order by  percent_population_infected desc

--Showing countries with highest death count per population

select location,max(cast(total_deaths as int))as total_death_count
from Covid_Project..CovidDeaths1 
--where location like '%ndia%'
where continent is not null
group by location
order by  total_death_count desc

--LETS BREAK THINGS DOWN BY CONTINENT

select continent,max(cast(total_deaths as int))as total_death_count
from Covid_Project..CovidDeaths1 
--where location like '%ndia%'
group by continent
order by  total_death_count desc

-- In above case null continent is also added so remove it by using where continent is not null

select continent,max(cast(total_deaths as int))as total_death_count
from Covid_Project..CovidDeaths1 
--where location like '%ndia%'
where continent is not null
group by continent
order by  total_death_count desc

--SHOWING THE CONTINENTS WITH THE  HIGHEST DEATH COUNT PER POPULATION

select continent,max(cast(total_deaths as int))as total_death_count
from Covid_Project..CovidDeaths1 
--where location like '%ndia%'
where continent is not null
group by continent
order by  total_death_count desc


-- GLOBAL NUMBERS

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Covid_Project..CovidDeaths1 
--where location like '%indi%' and 
WHERE continent is not null
order by 1,2

--


select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100  as Death_percentage
from Covid_Project..CovidDeaths1 
--where location like '%indi%' and 
WHERE continent is not null
group by date
order by 1,2


--total cases, total deaths and death percentage around the world

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100  as Death_percentage
from Covid_Project..CovidDeaths1 
--where location like '%indi%' and 
WHERE continent is not null
--group by date
order by 1,2


--COVIDVACCCINATIONS11 TABLE

select *
from Covid_Project..CovidVaccinations11

--JOIN TWO TABLES

select *
from Covid_Project..CovidDeaths1 as dea
join Covid_Project..CovidVaccinations11 as vac
  on dea.location  = vac.location and
  dea.date = vac.date


  --looking at total population vs vaccinations

  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Covid_Project..CovidDeaths1 as dea
join Covid_Project..CovidVaccinations11 as vac
  on dea.location  = vac.location and
  dea.date = vac.date
  where dea.continent is not null
  order by 2,3 


-- using window function to get sum of new vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER ( Partition by  dea.location)
from Covid_Project..CovidDeaths1 as dea
join Covid_Project..CovidVaccinations11 as vac
  on dea.location  = vac.location and
  dea.date = vac.date
  where dea.continent is not null
  order by 2,3 


  -- Total vaccination at any particular date

  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER ( Partition by  dea.location order by dea.date) as rolling_people_vaccinated
from Covid_Project..CovidDeaths1 as dea
join Covid_Project..CovidVaccinations11 as vac
  on dea.location  = vac.location and
  dea.date = vac.date
  where dea.continent is not null
  order by 2,3 


  -- USE CTE

  with popuvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
  as
  (
   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER ( Partition by  dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Covid_Project..CovidDeaths1 as dea
join Covid_Project..CovidVaccinations11 as vac
  on dea.location  = vac.location and
  dea.date = vac.date
  where dea.continent is not null
  --order by 2,3 
)
select * , (rolling_people_vaccinated/population)*100
from popuvsvac

-- TEMP TABLE


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
( 
continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rolling_people_vaccinated numeric
 )

insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER ( Partition by  dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Covid_Project..CovidDeaths1 as dea
join Covid_Project..CovidVaccinations11 as vac
  on dea.location  = vac.location and
  dea.date = vac.date
  --where dea.continent is not null
  --order by 2,3 
  select * , (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualization


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER ( Partition by  dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Covid_Project..CovidDeaths1 as dea
join Covid_Project..CovidVaccinations11 as vac
  on dea.location  = vac.location and
  dea.date = vac.date
  where dea.continent is not null
  --order by 2,3 

select*
from PercentPopulationVaccinated