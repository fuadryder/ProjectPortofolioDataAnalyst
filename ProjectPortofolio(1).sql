SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--- Looking at Total cases vs Total deaths

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM CovidDeaths
where location like '%Indonesia%'
ORDER BY 1,2

--- Looking at Total cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as deathPercentage
FROM CovidDeaths
where location like '%Indonesia%'
ORDER BY 1,2

-- Looking at Countries with highiest infected compared to population
SELECT location, population, MAX(total_cases) AS HighiestInfection, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
--where location like '%Indonesia%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--- Showing countries with highest Death
SELECT location, MAX(cast( [total_deaths]as int)) AS TotalDeathCount
FROM CovidDeaths
where continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--- Showing global 
SELECT SUM(new_cases) as total_cases, SUM (cast (total_deaths as int)) as total_deaths, SUM (new_cases) / SUM (cast (total_deaths as int)) *100 AS DeathPerCasesPercentage
FROM CovidDeaths
WHERE continent is not NULL
--GROUP BY continent, population
--ORDER BY TotalDeathContinent DESC

---- Looking Total population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date,
dea.location) as RollingPeopleVaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


--- USE CTE to look percentage of RollongPeopleVaccinated

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date,
dea.location) as RollingPeopleVaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3 )
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVSVac


--- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date,
dea.location) as RollingPeopleVaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data to visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.date,
dea.location) as RollingPeopleVaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

