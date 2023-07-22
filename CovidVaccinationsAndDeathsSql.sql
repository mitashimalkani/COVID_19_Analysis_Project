SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total deaths
SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows % of population that has COVID 
SELECT location, date, population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS COVIDPercentage
FROM PortfolioProject..covidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopInfected DESC

--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by Continent 
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers 

SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(NULLIF(new_cases, 0)) *100 as PercenatgeGlobal
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 1,2

--Using CTE
WITH PopsVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 1,2
)

select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopsVsVac
where RollingPeopleVaccinated is not null

--Creating View to store data for later visualizations
CREATE VIEW PercentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
from PercentagePopulationVaccinated
