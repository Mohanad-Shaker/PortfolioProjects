/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select *
from [portfolio project 1]..CovidDeaths
where continent is not null
order by 3,4

select *
from [portfolio project 1]..CovidVaccinations
where continent is not null
order by 3,4


-- Select Data that we are going to start with

Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio project 1]..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows chances of dying if you catch covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From [portfolio project 1]..CovidDeaths
where location = 'Egypt'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as infectedpopulation
From [portfolio project 1]..CovidDeaths
--where location = 'Egypt'
where continent is not null 
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as highestcases, max((total_cases/population))*100 as highestinfectedpopulation
From [portfolio project 1]..CovidDeaths
where continent is not null 
group by location, population
order by highestinfectedpopulation desc


-- Countries with Highest Death Count per Population


Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From [portfolio project 1]..CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc


-- contintents with the highest Death Count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project 1]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [portfolio project 1]..CovidDeaths
where continent is not null 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [portfolio project 1]..CovidDeaths
where continent is not null 
group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows count of people vaccinated from each country

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
from [portfolio project 1]..CovidDeaths dea
join [portfolio project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
From [portfolio project 1]..CovidDeaths dea
Join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (TotalPeopleVaccinated/Population)*100 as percpeoplevaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From [portfolio project 1]..CovidDeaths dea
Join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select *, (PeopleVaccinated/Population)*100 as percpeoplevaccinated
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

--Create View PercentPopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--From [portfolio project 1]..CovidDeaths dea
--Join [portfolio project 1]..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null