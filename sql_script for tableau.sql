Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM covid_deaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


SELECT 	continent,
		SUM(cast(new_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS  NOT NULL AND continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT 	location,
		population,
		MAX(total_cases * 1.0) as HighestInfecionCount ,
		MAX(ROUND((total_cases * 1.0 / population) * 100,2))  AS PercentPopulationInfected
FROM covid_deaths
GROUP BY population, location
ORDER BY  percentpopulationinfected DESC

SELECT 	location,
		population,
		date,
		MAX(total_cases * 1.0) as HighestInfecionCount ,
		MAX(ROUND((total_cases * 1.0 / population) * 100,2))  AS PercentPopulationInfected
FROM covid_deaths
GROUP BY population, location,date
ORDER BY  percentpopulationinfected DESC