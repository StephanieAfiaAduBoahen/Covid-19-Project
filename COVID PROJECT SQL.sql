SELECT [location], [date], (total_cases),  new_cases, total_deaths, population
FROM CovidDeath
ORDER BY 1, 2

SELECT [location], continent
FROM CovidDeath
Order BY 1

SELECT *
FROM CovidVaccinations

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE [location] like '%Canada%'
and continent is not NULL
ORDER BY 1, 2

--WHAT PERCENTAGE OF THE POPULATION GOT COVID- TOTAL CASES VS POPULATION
SELECT location, date, population,  total_cases, (total_cases/population)*100 as PercentageOfCovidCases
FROM CovidDeath
WHERE [location] like '%Canada%'
ORDER BY 1, 2

--Countries with higher percentage rate compared to population
SELECT location, population,  Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentageOfCovidCases
FROM CovidDeath
--WHERE [location] like '%Canada%'
GROUP BY location, population
ORDER BY PercentageOfCovidCases DESC

--Countries with highest death count per population
SELECT location, Max(total_deaths) as TotalDeathCount
FROM CovidDeath
--WHERE [location] like '%Canada%'
WHERE continent is not NULL
GROUP BY location
ORDER BY  TotalDeathCount DESC

--BREAKDOWN BY CONTINENT
SELECT continent, Max(total_deaths) as TotalDeathCount
FROM CovidDeath
--WHERE [location] like '%Canada%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT [date], SUM(new_cases),SUM(new_deaths), SUM(new_deaths) / NULLIF(SUM(new_cases), 0)
FROM CovidDeath
--WHERE [location] like '%Canada%'
WHERE continent is not NULL
GROUP BY [date]
ORDER BY  1, 2

SELECT SUM(new_cases),SUM(new_deaths), SUM(new_deaths) / NULLIF(SUM(new_cases), 0)
FROM CovidDeath
--WHERE [location] like '%Canada%'
WHERE continent is not NULL
--GROUP BY [date]
ORDER BY  1, 2


--Total Population VS Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeath dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3


--CREATE CTE- POPUVSVACC
WITH PopuVSVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopuVSVacc


--TEMPTABLE

DROP TABLE IF EXISTS #PERCENTOFPOPULATIONVACCINATED
CREATE TABLE #PERCENTOFPOPULATIONVACCINATED
(
continent VARCHAR (255),
location VARCHAR (255),
date DATE,
population FLOAT,
New_Vaccinations FLOAT,
RollingPeopleVaccinated FLOAT
)
 

INSERT INTO #PERCENTOFPOPULATIONVACCINATED
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PERCENTOFPOPULATIONVACCINATED



--CREATE VIEW
CREATE VIEW PERCENTOFPOPULATIONVACCINATED as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PERCENTOFPOPULATIONVACCINATED

