SELECT *
FROM PortfolioProject..CovidDeaths

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- 2. Total cases by continents

SELECT continent AS Continent, SUM(total_cases) AS TotalCases, SUM(convert(INT, new_deaths)) AS TotalDeaths
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- 3. By country with lastest total infected cases

SELECT location AS Country, population AS Population, MAX(total_cases) AS TotalCases, (MAX(total_cases)/MAX(Population))*100 AS PercentOfPopulationInfections
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentOfPopulationInfections DESC;

--4.  By country with lastest total infected cases (included date)

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


--5. Show a infections in Cambodia

SELECT Dea.location, Dea.date, Dea.population, total_cases, total_deaths, people_vaccinated, (people_vaccinated/dea.population)*100 AS PercentPopulationVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL AND Dea.location LIKE '%Cambodia%'
ORDER BY Dea.date