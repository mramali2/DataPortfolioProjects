-- Both databases:
-- SELECT *
-- FROM PortfolioProject..covid_deaths
-- Order by 3,4

-- SELECT *
-- FROM PortfolioProject..covid_vaccinations
-- Order by 3,4

--Relevant fields from databases:

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2

--Total Cases v Total Deaths:


-- SELECT location, total_cases, date, total_deaths, (1.00*total_deaths/total_cases) *100 as DeathPercentage
-- FROM covid_deaths
-- WHERE continent IS NOT NULL
-- ORDER BY 1,2

--Kept getting values of 0 when trying to calculate death rate - likely DeathRate was an integer field so kept rounding down to 0.
--Found fix online to multiply total_deaths by 1.00

-- Cases as percenatge of population in the UK:
-- SELECT location, date, population, total_cases, total_deaths, (1.00*total_deaths/total_cases) *100 as DeathPercentage, (1.00*total_cases/population)*100 as CasePercentageByPop
-- FROM covid_deaths
-- WHERE location like '%Kingdom'
-- ORDER BY 1,2

--Looking at countries with highest infection rate compared to population:
-- SELECT location, population, MAX(total_cases) as CaseTotal, ((1.00*MAX(total_cases))/population)*100 as InfectionPercent
-- FROM covid_deaths
-- WHERE continent IS NOT NULL
-- GROUP BY [location], population
-- Order By InfectionPercent DESC

--Looking at countries with highest death rate compared to population:
SELECT location, population, MAX(total_deaths) as DeathTotal, ((1.00*MAX(total_deaths))/population)*100 as DeathPercentByPop
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY [location], population
Order By DeathPercentByPop DESC

--Ranking total deaths from COVID

SELECT location, MAX(total_deaths) as TotalDeaths
FROM covid_deaths
Where continent IS NOT NULL
Group By location
Order By 2 Desc

--Total deaths by continent

SELECT location, MAX(total_deaths) as TotalDeaths
FROM covid_deaths
Where continent is NULL
AND location in ('Europe','Asia','North America','South America','Africa','Oceania')
Group By location
Order By 2 Desc

SELECT continent, MAX(total_deaths) DeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC

--Global Daily new cases and deaths

SELECT [date], SUM(new_cases) GlobalDailyNewCases ,SUM(new_deaths) GlobalDailyNewDeaths,
CASE
    WHEN SUM(new_cases) = 0 THEN 0
    ELSE (1.00*SUM(new_deaths)/SUM(new_cases))*100 
    END as GlobalDailyDeathPercent
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY [date]
ORDER BY 1,2

--Overall global death percent

SELECT  SUM(new_cases) GlobalCases ,SUM(new_deaths) GlobalDeaths,
CASE
    WHEN SUM(new_cases) = 0 THEN 0
    ELSE (1.00*SUM(new_deaths)/SUM(new_cases))*100 
    END as GlobalDeathPercent
FROM covid_deaths
WHERE continent IS NOT NULL


--COVID VACCINATIONS
WITH PopvsVac (continent, location, date, population, new_vaccincations, RunningVaccinationCount)
AS
(
SELECT dea.continent,dea.[location],dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) RunningVaccinationCount
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ((1.00*RunningVaccinationCount)/population)*100 PercentPopVaccinated
FROM PopvsVac
ORDER BY 2,3

GO

--Creating view to store data for visualisations

CREATE VIEW GlobalDailyCases AS 
SELECT [date], SUM(new_cases) GlobalDailyNewCases ,SUM(new_deaths) GlobalDailyNewDeaths,
CASE
    WHEN SUM(new_cases) = 0 THEN 0
    ELSE (1.00*SUM(new_deaths)/SUM(new_cases))*100 
    END as GlobalDailyDeathPercent
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY [date]

GO

CREATE VIEW PopVaccinated 
AS
SELECT dea.continent,dea.[location],dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) RunningVaccinationCount
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.[location] = vac.[location]
and dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
