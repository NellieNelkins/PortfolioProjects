select *
from PortfolioProject..covid_deaths
order by 3,4

select *
from PortfolioProject..covid_vacination
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
order by 1,2

-- total cases vs total deaths in %

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths
order by 1,2


-- Ratio of dying from covid in a country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths
where location like '%Africa%'
order by 1,2


-- total cases vs population who got infected a country 

select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..covid_deaths
where location like '%Africa%'
order by 1,2


select location, population, max(total_cases) as MostInfectionCount, max((total_cases/population))*100 as MostInfectionCountPercentage
from PortfolioProject..covid_deaths
group by population, location
order by MostInfectionCountPercentage desc



select location, max(cast (total_deaths as int))as MostdeathsCount
from PortfolioProject..covid_deaths
where continent is not null
group by location
order by MostdeathsCount desc



select *
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4



select location, max(cast (total_deaths as int))as MostdeathsCount
from PortfolioProject..covid_deaths
where continent is  null
group by location
order by MostdeathsCount desc


select continent, max(cast (total_deaths as int))as MostdeathsCount
from PortfolioProject..covid_deaths
where continent is  not null
group by continent
order by MostdeathsCount desc


SELECT
    date,
    SUM(new_cases) AS GlobalCases,
    SUM(CAST(new_deaths AS INT)) AS GlobalDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
    END AS GlobalDeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;
  

SELECT
   -- date,
    SUM(new_cases) AS GlobalCases,
    SUM(CAST(new_deaths AS INT)) AS GlobalDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
    END AS GlobalDeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


select *
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vacination vac
	on dea.location = vac.location
	and dea.date = vac.date


SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM
    PortfolioProject..covid_deaths dea
JOIN
    PortfolioProject..covid_vacination vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
order by 
		2, 3;


 WITH PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations) AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
    FROM
        PortfolioProject..covid_deaths dea
    JOIN
        PortfolioProject..covid_vacination vac
    ON
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT * , (TotalVaccinations/POPULATION)*100 AS TotalVaccinationsPercentage
FROM PopvsVac
ORDER BY location, date;


drop table if exists #globalpopvac
CREATE TABLE #globalpopvac 
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
TotalVaccinations numeric
)

Insert into #globalpopvac
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM
    PortfolioProject..covid_deaths dea
JOIN
    PortfolioProject..covid_vacination vac
ON
    dea.location = vac.location
    AND dea.date = vac.date

SELECT * , (TotalVaccinations/POPULATION)*100 AS TotalVaccinationsPercentage
FROM #globalpopvac


CREATE VIEW TotalVacPercentage AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM
    PortfolioProject..covid_deaths dea
JOIN
    PortfolioProject..covid_vacination vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

select *
from dbo.TotalVacPercentage
