SELECT * FROM PortfolioProject..CovidDeaths;

SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at total cases and total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
	FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Cambodia%'
ORDER BY 1, 2

-- Looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS Infected_Percentage
	FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%State%'
ORDER BY 1, 2

-- Looking at with highest infection rate
SELECT location, population, MAX(total_cases) AS Highest_InfectionC, MAX((total_cases/population)) * 100 AS Highest_Infected_Percentage
	FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Highest_Infected_Percentage DESC

-- Country with highest death count per population

SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeaths
	FROM PortfolioProject..CovidDeaths
--WHERE Location NOT IN ('World', 'Europe', 'Africa', 
--				'South America', 'Asia', 'North America',
--				'European Union')
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC

-- Highest death count per population by Continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeaths
	FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS deaths_percentage
	FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Total population vs vaccinations
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location 
ORDER BY Dea.location, Dea.date) AS Rolling_Vaccinated
	FROM PortfolioProject..CovidDeaths Dea
		JOIN PortfolioProject..CovidVaccinations$ Vac
	ON Dea.date = Vac.date AND Dea.location = Vac.location
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3;

WITH Popvsvac (continent, location, date, population, New_Vaccinations, Rolling_Vaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location 
ORDER BY Dea.location, Dea.date) AS Rolling_Vaccinated
	FROM PortfolioProject..CovidDeaths Dea
		JOIN PortfolioProject..CovidVaccinations$ Vac
	ON Dea.date = Vac.date AND Dea.location = Vac.location
WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3;
)

SELECT *, (Rolling_Vaccinated / population) * 100 AS Percentage_Vaccination
FROM Popvsvac


-- Create temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location 
ORDER BY Dea.location, Dea.date) AS Rolling_Vaccinated
	FROM PortfolioProject..CovidDeaths Dea
		JOIN PortfolioProject..CovidVaccinations$ Vac
	ON Dea.date = Vac.date AND Dea.location = Vac.location
WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3;

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(INT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location 
ORDER BY Dea.location, Dea.date) AS Rolling_Vaccinated
	FROM PortfolioProject..CovidDeaths Dea
		JOIN PortfolioProject..CovidVaccinations$ Vac
	ON Dea.date = Vac.date AND Dea.location = Vac.location
WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3;

SELECT * FROM PercentPopulationVaccinated