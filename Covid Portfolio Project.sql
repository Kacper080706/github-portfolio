SELECT * FROM
PortfolioProject..CovidDeaths
order by 3,4

--Select Data that we are going to use in project
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in Poland
SELECT 
    location, 
    TRY_CONVERT(DATE, date, 104) AS date,  
    total_cases, 
    total_deaths, 
    ROUND(ISNULL((CAST(total_deaths AS FLOAT) / CAST(NULLIF(total_cases, 0) AS FLOAT)) * 100, 0),2) AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%poland%'
AND continent is not null
ORDER BY 1,2;

-- Looking at total cases vs population
--show what percentage of population got Covid
SELECT 
    location, 
    TRY_CONVERT(DATE, date, 104) AS date,  
	population,
    total_cases, 
    ROUND(ISNULL((CAST(total_cases AS FLOAT) / CAST(NULLIF(population, 0) AS FLOAT)) * 100, 0),2) AS PercentOfInfectionInPopulation
FROM PortfolioProject..CovidDeaths
WHERE location like '%poland%'
AND continent is not null
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT 
    location,
    CAST(population AS BIGINT) AS population,
    MAX(CAST(total_cases AS FLOAT)) AS HighestInfectionCount,
    MAX(ROUND(ISNULL((CAST(total_cases AS FLOAT) / CAST(NULLIF(CAST(population AS BIGINT), 0) AS FLOAT)) * 100, 0), 2)) AS PercentOfInfectionInPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentOfInfectionInPopulation desc;

-- Showing countries with highest death count per population
SELECT 
    location,
    CAST(population AS BIGINT) AS population,
    MAX(CAST(total_deaths AS FLOAT)) AS HighestDeathCount,
    MAX(ROUND(ISNULL((CAST(total_deaths AS FLOAT) / CAST(NULLIF(CAST(population AS BIGINT), 0) AS FLOAT)) * 100, 0), 2)) AS PercentOfDeathsInPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentOfDeathsInPopulation desc;

-- Deaths count by continent
SELECT 
    continent,   
    MAX(CAST(total_deaths AS FLOAT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and continent <> ''
GROUP BY continent
ORDER BY HighestDeathCount desc;

-- Global numbers

SELECT 
    TRY_CONVERT(DATE, date, 104) AS date, 
    SUM(CAST(new_cases AS FLOAT)) AS Total_Cases, 
    SUM(CAST(new_deaths AS FLOAT)) AS Total_Deaths,
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY date
ORDER BY 1, 2

-- Looking at Total Vaccination vs Population 

SELECT 
    dea.continent, 
    dea.location, 
    TRY_CONVERT(DATE, dea.date, 104) AS date, 
    CAST(dea.population AS FLOAT) AS Population, 
    CAST(vac.new_vaccinations AS FLOAT) AS New_Vaccinations, 
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (
        PARTITION BY dea.location ORDER BY TRY_CONVERT(DATE, dea.date, 104)
    ) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
LEFT JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND TRY_CONVERT(DATE, dea.date, 104) = TRY_CONVERT(DATE, vac.date, 104) 
WHERE dea.continent IS NOT NULL 
  AND dea.continent <> '' 
  AND vac.new_vaccinations IS NOT NULL 
  AND vac.new_vaccinations <> ''; 

-- Creating a view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent, 
    dea.location, 
    TRY_CONVERT(DATE, dea.date, 104) AS date, 
    CAST(dea.population AS FLOAT) AS Population, 
    CAST(vac.new_vaccinations AS FLOAT) AS New_Vaccinations, 
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (
        PARTITION BY dea.location ORDER BY TRY_CONVERT(DATE, dea.date, 104)
    ) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
LEFT JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND TRY_CONVERT(DATE, dea.date, 104) = TRY_CONVERT(DATE, vac.date, 104) 
WHERE dea.continent IS NOT NULL 
  AND dea.continent <> '' 
  AND vac.new_vaccinations IS NOT NULL 
  AND vac.new_vaccinations <> ''; 

  SELECT * FROM 
  PercentPopulationVaccinated




