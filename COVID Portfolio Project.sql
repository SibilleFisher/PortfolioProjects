select *
from [Portfolio Project]..[CovidDeaths-csv]
order by 3,4

--select *
--from [Portfolio Project]..[CovidVaccinations-csv]
--order by 3,4

--select Data that we are going to be using
select location, date, total_cases,new_cases, total_deaths, population
from [Portfolio Project]..[CovidDeaths-csv]
order by 1,2

--Looking at total cases vs total deaths
--shows percentage of deaths
SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       CASE 
           WHEN TRY_CAST(total_cases AS DECIMAL) = 0 THEN 0 
           ELSE (TRY_CAST(total_deaths AS DECIMAL) / TRY_CAST(total_cases AS DECIMAL)) * 100 
       END AS DeathPercentage
FROM [Portfolio Project]..[CovidDeaths-csv]
WHERE location LIKE '%states%'
  AND TRY_CAST(total_cases AS DECIMAL) IS NOT NULL
  AND TRY_CAST(total_deaths AS DECIMAL) IS NOT NULL
ORDER BY location, date;

--looking at total cases vs population
--shows the percenteage of the population that got Covid
SELECT location, 
       date, 
       total_cases, 
       population, 
       CASE 
           WHEN TRY_CAST(population AS DECIMAL) = 0 THEN 0 
           ELSE (TRY_CAST(total_cases AS DECIMAL) / TRY_CAST(population AS DECIMAL)) * 100 
       END AS CasesPercentage
FROM [Portfolio Project]..[CovidDeaths-csv]
WHERE TRY_CAST(total_cases AS DECIMAL) IS NOT NULL
  AND TRY_CAST(population AS DECIMAL) IS NOT NULL
--WHERE location LIKE '%states%' 
ORDER BY location, date;

--looking at countries with highest infection rate compared to population
SELECT location, 
       population, 
       MAX(TRY_CAST(total_cases AS DECIMAL)) AS maxinfectioncount, 
       (MAX(TRY_CAST(total_cases AS DECIMAL)) / MAX(TRY_CAST(population AS DECIMAL))) * 100 AS PERCENTOFPOPINFECTED,
       MAX(TRY_CAST(population AS DECIMAL)) AS population
FROM [Portfolio Project]..[CovidDeaths-csv]
WHERE TRY_CAST(total_cases AS DECIMAL) IS NOT NULL
  AND TRY_CAST(population AS DECIMAL) IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PERCENTOFPOPINFECTED DESC;

--Showing countries with highest death count by popullation
SELECT location,  
       MAX(TRY_CAST(total_deaths AS DECIMAL)) AS totaldeathcount
FROM [Portfolio Project]..[CovidDeaths-csv]
WHERE TRY_CAST(total_deaths AS DECIMAL) IS NOT NULL
and continent is not null
--WHERE location LIKE '%states%'
GROUP BY location
ORDER BY totaldeathcount DESC;

---Looking at the data by continent
SELECT continent,  
       MAX(TRY_CAST(total_deaths AS DECIMAL)) AS totaldeathcount
FROM [Portfolio Project]..[CovidDeaths-csv]
WHERE continent is not null
and continent <>''
GROUP BY continent
ORDER BY totaldeathcount DESC;

---Global numbers
SELECT 
    SUM(TRY_CAST(new_cases AS DECIMAL)) AS total_cases,
    SUM(TRY_CAST(new_deaths AS DECIMAL)) AS total_deaths,
    CASE 
        WHEN SUM(TRY_CAST(new_cases AS DECIMAL)) = 0 THEN 0 
        ELSE (SUM(TRY_CAST(new_deaths AS DECIMAL)) / SUM(TRY_CAST(new_cases AS DECIMAL))) * 100
    END AS Deathpercentage
FROM [Portfolio Project]..[CovidDeaths-csv]
WHERE continent IS NOT NULL
  AND TRY_CAST(new_cases AS DECIMAL) IS NOT NULL
  AND TRY_CAST(new_deaths AS DECIMAL) IS NOT NULL
ORDER BY total_cases DESC, total_deaths DESC;

---looking at the total population vs total vaccinations
with popvsvac (Continent, Location, Date, population, New_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)as Rollingpeoplevaccinated
from [Portfolio Project]..[CovidDeaths-csv] dea
join [Portfolio Project]..[CovidVaccinations-csv] vac
	on dea.location = vac.location
	and dea.date= vac.date
	WHERE dea.continent IS NOT NULL
	and dea.continent <>''
--ORDER BY 2,3
)
SELECT *,
       CASE 
           WHEN population = 0 THEN 0
           ELSE (Rollingpeoplevaccinated / population) * 100
       END AS VaccinationPercentage
FROM popvsvac;

--Temp table
DROP TABLE if exists #Percentpopvac
CREATE TABLE #Percentpopvac 
(
    Continent NVARCHAR(255),
    location NVARCHAR(255),
    Date DATETIME,
    population NUMERIC,
    New_vaccinations NUMERIC,
    Rollingpeoplevaccinated NUMERIC
);

INSERT INTO #Percentpopvac
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       TRY_CAST(dea.population AS NUMERIC), 
       TRY_CAST(vac.new_vaccinations AS NUMERIC),
       SUM(TRY_CAST(vac.new_vaccinations AS NUMERIC)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM [Portfolio Project]..[CovidDeaths-csv] dea
JOIN [Portfolio Project]..[CovidVaccinations-csv] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
  AND dea.continent <> '';

-- Check for rows where conversion failed (NULL results)
SELECT *
FROM #Percentpopvac
WHERE population IS NULL OR New_vaccinations IS NULL;

-- Select the vaccination percentage
SELECT *,
       CASE 
           WHEN population = 0 THEN 0
           ELSE (Rollingpeoplevaccinated / population) * 100
       END AS VaccinationPercentage
FROM #Percentpopvac;

create view Percentpopvac as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)as Rollingpeoplevaccinated
from [Portfolio Project]..[CovidDeaths-csv] dea
join [Portfolio Project]..[CovidVaccinations-csv] vac
	on dea.location = vac.location
	and dea.date= vac.date
	WHERE dea.continent IS NOT NULL
	and dea.continent <>''

select * from Percentpopvac

