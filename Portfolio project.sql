
SELECT *
FROM CovidDeath
/* Deducing the percentahe death in Nigeria */
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PcntDeath
FROM CovidDeath
WHERE total_cases is NOT NULL AND total_deaths is NOT NULL AND location like '%Nigeria%'
ORDER BY 1,2
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PcntDeath
FROM CovidDeath
WHERE total_cases is NOT NULL AND total_deaths is NOT NULL AND location like '%Australia%'
ORDER BY 1,2

/*Deducing the percentage death for top 3 countries*/
/*United States*/
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PcntDeath
FROM CovidDeath
WHERE total_cases is NOT NULL AND total_deaths is NOT NULL AND location like '%States%'
ORDER BY 1,2

/*India*/
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PcntDeath
FROM CovidDeath
WHERE total_cases is NOT NULL AND total_deaths is NOT NULL AND location like '%India%'
ORDER BY 1,2

/*France*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PcntDeath
FROM CovidDeath
WHERE total_cases is NOT NULL AND total_deaths is NOT NULL AND location like '%France%'
ORDER BY 1,2

/* Deducing the percentage of population infected  Nigeria and Australia*/

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PcntPopinfected
FROM CovidDeath
WHERE total_cases is NOT NULL AND total_deaths is NOT NULL AND location like '%Nigeria%'
ORDER BY 1,2
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PcntPopinfected
FROM CovidDeath
WHERE total_cases is NOT NULL AND total_deaths is NOT NULL AND location like '%Australia%'
ORDER BY 1,2

SELECT location, date,  population, total_cases, (total_cases/population)*100 AS PcntPopinfected
FROM CovidDeath
WHERE location like '%states%'
ORDER BY 1,2

/* Countries with Highest infection rate compared to population */

SELECT location,population, MAX(total_cases) AS HighestinfectionRate, MAX((total_cases/population))*100 AS PcntPopinfected
FROM CovidDeath
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PcntPopinfected DESC

/*Countries with the highest death count compared to its population */
SELECT location, population, MAX(total_deaths) AS TotalDeathRate
FROM CovidDeath
WHERE continent is NOT NULL 
GROUP BY Location,population
ORDER BY TotalDeathRate DESC

/* Calculating the highest date rate by continent */
SELECT location, MAX(total_deaths) AS TotalDeathRate
FROM CovidDeath
WHERE continent is NULL 
GROUP BY location
ORDER BY TotalDeathRate DESC

/* Calculating the highest death rate per day */


SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 AS PcntDeath
FROM CovidDeath
WHERE continent is NOT NULL 
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 AS PcntDeath
FROM CovidDeath
WHERE continent is NOT NULL 
--GROUP BY date
ORDER BY 1,2

/* Joining both tables */

SELECT *
FROM CovidVaccinations

SELECT Dea.continent, Dea.location, Dea.date,Dea.population, Vax.new_vaccinations
FROM CovidVaccinations Vax
JOIN CovidDeath Dea
	ON Vax.location = Dea.location
	and Vax.date = Dea.date
	WHERE Dea.continent is NOT NULL
	Order by 1,2,3

/* Comparing total population to vaccination */

SELECT Dea.continent, Dea.location, Dea.date,Dea.population, Vax.new_vaccinations, 
SUM(CONVERT(numeric,Vax.new_vaccinations)) OVER (PARTITION BY Dea.location Order by Dea.location, Dea.date) AS RollingVaxxedSum
FROM CovidVaccinations Vax
JOIN CovidDeath Dea
	ON Vax.location = Dea.location
	and Vax.date = Dea.date
	WHERE Dea.continent is NOT NULL
	Order by 2,3

/* Using CTE */
WITH PopVax (continent, location, date, population, new_vaccinations, RollingVaxxedSum)
as
(
SELECT Dea.continent, Dea.location, Dea.date,Dea.population, Vax.new_vaccinations, 
SUM(CONVERT(numeric,Vax.new_vaccinations)) OVER (PARTITION BY Dea.location Order by Dea.location, Dea.date) AS RollingVaxxedSum
FROM CovidVaccinations Vax
JOIN CovidDeath Dea
	ON Vax.location = Dea.location
	and Vax.date = Dea.date
	WHERE Dea.continent is NOT NULL
	--Order by 2,3
)
SELECT *, (RollingVaxxedSum/population)*100
FROM PopVax

/* Using Temp Table */

DROP TABLE if exists #PcntPopVaxxed
Create Table #PcntPopVaxxed
(
Continent nvarchar(255), 
 Location nvarchar(255), 
 Date datetime, 
 Population numeric, 
 New_vaccination numeric,
 RollingVaxxedSum numeric)

Insert into #PcntPopVaxxed
SELECT Dea.continent, Dea.location, Dea.date,Dea.population, Vax.new_vaccinations, 
SUM(CONVERT(numeric,Vax.new_vaccinations)) OVER (PARTITION BY Dea.location Order by Dea.location, Dea.date) AS RollingVaxxedSum
FROM CovidVaccinations Vax
JOIN CovidDeath Dea
	ON Vax.location = Dea.location
	and Vax.date = Dea.date
	--WHERE Dea.continent is NOT NULL
	Order by 2,3

	SELECT *, (RollingVaxxedSum/population)*100
	FROM  #PcntPopVaxxed

/* Creating View */
CREATE View PcntPopVaxxed as

SELECT Dea.continent, Dea.location, Dea.date,Dea.population, Vax.new_vaccinations, 
SUM(CONVERT(numeric,Vax.new_vaccinations)) OVER (PARTITION BY Dea.location Order by Dea.location, Dea.date) AS RollingVaxxedSum
FROM CovidVaccinations Vax
JOIN CovidDeath Dea
	ON Vax.location = Dea.location
	and Vax.date = Dea.date
	WHERE Dea.continent is NOT NULL
	--Order by 2,3

SELECT *
FROM PcntPopVaxxed