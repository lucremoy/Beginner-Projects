select *
from PortfolioProject..CovidDeaths
where continent is null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we're going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'CovidDeaths'

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'CovidVaccinations'

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float

--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location='Nigeria'
order by 1,2

--looking at total cases vs population

select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as infected_percentage
from PortfolioProject..CovidDeaths
where location='Nigeria'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as highest_infection_percent
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by highest_infection_percent desc

--looking at countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc

--breaking things down by continent

select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null and location NOT LIKE '%income%'
group by continent
order by total_death_count desc

--global numbers

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

SET ANSI_WARNINGS OFF;
GO

--looking at total population vs vaccinations


--use CTE

with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date)as rolling_vaccinated
--, (rolling_vaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_vaccinated/population)*100
from pop_vs_vac


--temp table

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date)as rolling_vaccinated
--, (rolling_vaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rolling_vaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date)as rolling_vaccinated
--, (rolling_vaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3