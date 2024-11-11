select * from PortfolioProject.dbo.CovidDeaths
where continent is NOT NULL
order by 3,4

select * from PortfolioProject.dbo.CovidVaccinations
order by 3,4
select location,date,total_cases,new_cases,total_deaths, population from PortfolioProject..CovidDeaths
order by 1,2

-- Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2

--Total Cases vs Population
select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2
-- countries Highest infection rate compare to population
select location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as MAXPercentageofPopulationInfected
from PortfolioProject..CovidDeaths
--where location like'%states%'
Group by population,location
order by MAXPercentageofPopulationInfected desc

-- showing countries with highest death perpopulation
select location,MAX(cast(total_deaths as int)) as HighestDeath
from PortfolioProject..CovidDeaths
--where location like'%states%'
where continent is NOT NULL
Group by location
order by HighestDeath desc

--BREAK THINGS DOWN BY CONTINENT
--showing continents with highest death perpopulation
select continent,MAX(cast(total_deaths as int)) as HighestDeath
from PortfolioProject..CovidDeaths
--where location like'%states%'
where continent is NoT NULL
Group by continent
order by HighestDeath desc

--GLOBAL NUMBERS
select date,SUM (new_cases) as total_new_cases, SUM (cast(new_deaths as int))as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like'%states%'
where continent IS NOT NULL
Group by date
order by 1,2

--LOOKING AT TOTAL POPULATION V/S VACCINATION
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location= vac.location
AND dea.date=vac.date
where dea.continent is not null
order by 2,3


--Use CTE
With Popvsvac(Continent,Location,Date,Population,new_Vaccinations,RollingPeopleVaccinated)
AS
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location= vac.location
AND dea.date=vac.date
--where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 AS peopleVaccinatedPercentage From Popvsvac 


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location= vac.location
AND dea.date=vac.date
--where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100 AS peopleVaccinatedPercentage From #PercentPopulationVaccinated

--CREATING VIEWS
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location= vac.location
AND dea.date=vac.date
where dea.continent is not null
--order by 2,3

--select * from PercentPopulationVaccinated