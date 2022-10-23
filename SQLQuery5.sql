SELECT *
FROM portfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM portfolioProject..CovidVaccination
--ORDER BY 3,4

-- SELECTING THE DATA THAT I WOULD BE USING 
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolioProject..CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--which shows the chances of death if you contract covid in our country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM portfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2 

--LOOKIUNG AT TOTAL CASES VS POPULATION
-- shows what percentage of population was affected
SELECT location,date,population, total_cases,(total_cases/population)*100 AS percent_population
FROM portfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2 

--LOOKING AT COUTNRY WITH AN HIGHEST INFECTION RATE
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM portfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

--LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- SORTING IT FURTHER DOWN BY CONTINENT
-- showing continents with highest death count
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 

--global
SELECT date,sum(new_cases) as total_cases,
sum (cast(new_deaths as int)) as total_deaths,
(SUM (cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 
-- in total
SELECT sum(new_cases) as total_cases,
sum (cast(new_deaths as int)) as total_deaths,
(SUM (cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

-- looking at total populatoion vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location ORDER BY dea.population, dea.date ) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
FROM portfolioProject..CovidDeaths dea 
JOIN portfolioProject..CovidVaccination vac
ON dea.location = vac.location
and  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 

-- now using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccination/Population)*100
From PopvsVac

--Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccination numeric,
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccination/Population)*100 
From #PercentPopulationVaccinated

--creating a view for tableau visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
