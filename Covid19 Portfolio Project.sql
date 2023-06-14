SELECT * 
FROM covid_deaths
WHERE continent IS not NULL  
AND continent != ''
ORDER BY location, date 

-- Selecting data we're going to use 

SELECT 	location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population 
FROM covid_deaths cd;



-- Looking at total_cases V. total_deaths 
-- Shows percentage of death by case 
SELECT 	location,
		date,
		total_cases,
		total_deaths,
		ROUND((total_deaths *1.0 / total_cases) * 100,2)  AS death_percentage
FROM covid_deaths 
WHERE location = 'France'
ORDER BY location, date;



-- Looking at total_cases V. population 
-- Shows percentage of population got Covid 
SELECT 	location,
		date,
		total_cases,
		population, 
		ROUND((total_cases * 1.0 / population) * 100,2)  AS PercentPopulationInfected
FROM covid_deaths 
--WHERE location = 'France'
ORDER BY location, date;



-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT 	location,
		population,
		MAX(total_cases * 1.0) as HighestInfecionCount ,
		MAX(ROUND((total_cases * 1.0 / population) * 100,2))  AS PercentPopulationInfected
FROM covid_deaths 
GROUP BY population, location 
ORDER BY  percentpopulationinfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT 	location, 
		MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths 
WHERE continent IS NOT NULL
  AND continent != ''
GROUP BY location 
ORDER BY TotalDeathCount DESC


-- Beaking things down by continent 

-- Showing Continents with Highest Death Count 

SELECT 	continent, 
		MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths 
WHERE continent IS  NOT NULL AND continent != ''
GROUP BY continent   
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS 

SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    ROUND((SUM(CAST(new_deaths AS float)) / SUM(new_cases)) * 100, 3) AS DeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL AND continent != ''
--GROUP BY date
ORDER BY total_cases;


-- Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM (CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
       --, (RollingPeopleVaccinated / population) * 100
FROM covid_deaths dea
JOIN covid_vacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.continent != ''
ORDER BY dea.location, dea.date 


-- USE CTE 

WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated) AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
           SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM covid_deaths dea
    JOIN covid_vacc vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL AND dea.continent != ''
)
SELECT *, ROUND(CAST(RollingPeopleVaccinated as float) / population * 100, 2) AS VaccinationRate
FROM PopvsVac

-- TEMP TABLE 

CREATE TABLE PercentPopulationVaccinated (
  Continent NVARCHAR(50),
  Location NVARCHAR(50),
  Date DATETIME,
  Population NUMERIC,
  New_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

WITH TempTable AS (
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM
    covid_deaths dea
  JOIN
    covid_vacc vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL AND dea.continent != ''
)
INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated
FROM TempTable;

SELECT *, ROUND(CAST(RollingPeopleVaccinated AS FLOAT) / Population * 100, 2) AS VaccinationRate
FROM PercentPopulationVaccinated;


-- Creating view to store data for later viz 

CREATE VIEW ViewPercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    covid_deaths dea
JOIN
    covid_vacc vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL AND dea.continent != '';

-- Verifying if the VIEW EXISTS/WORKS
SELECT name FROM sqlite_master WHERE type = 'view';
SELECT *
FROM ViewPercentPopulationVaccinated;





















