Select *
FROM covid_data.dbo.CovidDeaths$ as CD
WHERE continent is not null
ORDER BY 3,4

Select *
FROM covid_data.dbo.CovidVaccinations$ as CV
WHERE continent is not null
ORDER BY 3,4

--Selecting the data for our analysis

Select location, date, total_cases, new_cases, total_deaths, population
FROM covid_data.dbo.CovidDeaths$ as CD
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs. Total Deaths
-- Likelihood of Dying from Contraction of COVID-19

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_data.dbo.CovidDeaths$ as CD
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentContraction
FROM covid_data.dbo.CovidDeaths$ as CD
WHERE continent is not null
ORDER BY 1,2

-- Countries with Highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covid_data.dbo.CovidDeaths$ 
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with Highest Death Count per Capita

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/population))*100 as FatalityPercentage
FROM covid_data.dbo.CovidDeaths$ 
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 DESC

-- Deaths By Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM covid_data.dbo.CovidDeaths$ 
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC


-- Global Number Totals

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as FatalityPercentage
FROM covid_data.dbo.CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 

-- Total Population vs Vaccinations
-- JOINING Death and Vaccination Tables

WITH PopvsVacc (Continent, Location, date, population, new_vaccinations, RollingVaccinationCount)
as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (Partition BY cd.location ORDER BY cd.location, cd.date) as RollingVaccinationCount
FROM covid_data.dbo.CovidDeaths$ as cd
JOIN covid_data.dbo.CovidVaccinations$ as cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent is not null
)

SELECT *, (RollingVaccinationCount/population) as PctVaccinated
FROM PopvsVacc