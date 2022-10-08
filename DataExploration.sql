-- Checking Data collected is correct
select * from Projects..Deaths order by location, date

select * from Projects..Vaccinations order by 3,4

-- Selecting Data(Cases) for particular country
select location, date , population, total_cases, new_cases 
from Projects..Deaths where location = 'India'

select location, date , population, total_cases, new_cases 
from Projects..Deaths where location like '%Ken%'

-- Total Cases vs Total Deaths

select location, date, population, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeadPercentage 
from Projects..Deaths 
where continent is not null and location like 'Aus%'
order by DeadPercentage desc

-- Total Cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage 
from Projects..Deaths 
where continent is not null and location like 'Can%'
order by InfectedPercentage  desc

-- Countries with Highest Infection rate 
select location, population,max(total_cases) as HighCount, max((total_cases/population))*100 as InfectedPercentage 
from Projects..Deaths 
--where continent is not null
group by location , population 
order by InfectedPercentage desc

-- Countries with Highest Death Rate 
select location, max(cast(total_deaths as int)) as HighDeathCount, max((cast(total_deaths as int)/population))*100 as HighDeathPercentage 
from Projects..Deaths 
where continent is not null
group by location 
order by HighDeathCount desc

-- Continents with Highest Death Rate
select continent , max(cast(total_deaths as int)) as HighDeathCount, max((cast(total_deaths as int)/population))*100 as HighDeathPercentage 
from Projects..Deaths 
where continent is not null
group by continent 
order by HighDeathCount desc

-- Total Cases & Total Deaths per day all over globe

select date, sum(new_cases)as CaseTot, sum(cast(new_deaths as int)) as DeathTot , (sum(cast(new_deaths as int))/sum(new_cases))*100 as DP
from Projects..Deaths 
where continent is not null 
-- where location like 'Aus%'
group by date 
order by 1,2

-- Joining two tables

select * from Projects..Deaths d
join Projects..Vaccinations v
on d.location = v.location 
and d.date = v.date
order by 3,4

-- Total Population vs Vaccinated People
select d.continent , d.location , d.date , d.population , v.new_vaccinations from Projects..Deaths d
join Projects..Vaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 1,2,3

select d.continent , d.location , d.date , d.population , v.new_vaccinations , 
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPplVaccinated
from Projects..Deaths d
join Projects..Vaccinations v
on d.location = v.location 
and d.date = v.date
	where d.continent is not null
	order by 2,3 


-- Use CTE
with PopvsVac(Continent, Location, Date, Population, New_Vaccinations , RollingVaccinated)
as(
select d.continent , d.location , d.date , d.population , v.new_vaccinations , 
SUM(CONVERT(int,v.new_vaccinations)) OVER (partition by d.location order by d.location,d.date) 
as RollingVaccinated
from Projects..Deaths d
join Projects..Vaccinations v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2,3
)
select * , (RollingVaccinated/Population)*100 from PopvsVac

-- Temporary table
drop table if exists PPC
Create table PPC (
Continent  nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vacc numeric,
RollingVaccinated numeric)

insert into PPC 
select d.continent , d.location , d.date , d.population , v.new_vaccinations , 
SUM(CONVERT(int,v.new_vaccinations)) OVER (partition by d.location order by d.location,d.date)
as RollingVaccinated
from Projects..Deaths d
join Projects..Vaccinations v
on d.location = v.location 
and d.date = v.date
--where d.continent is not null
--order by 2,3

select * , (RollingVaccinated/Population)*100 from PPC 


-- Create View as for visulizations 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projects..Deaths dea
Join Projects..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Create View TotalCases_Deaths_per_day as
select date, sum(new_cases)as CaseTot, sum(cast(new_deaths as int)) as DeathTot , (sum(cast(new_deaths as int))/sum(new_cases))*100 as DP
from Projects..Deaths 
where continent is not null 
-- where location like 'Aus%'
group by date 
--order by 1,2

Create View totalcasesvstotaldeaths as
select location, date, population, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeadPercentage 
from Projects..Deaths 
where continent is not null and location like 'Aus%'
--order by DeadPercentage desc