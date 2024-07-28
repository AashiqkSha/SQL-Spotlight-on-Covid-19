SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


SELECT location,date,total_cases,total_deaths,population,new_cases
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total cases VS Total Death

SELECT location,date,total_cases,total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location,date,total_deaths,total_cases, CAST (total_deaths AS float)/CAST (total_cases AS float)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location,date,total_deaths,total_cases, CAST (total_deaths AS float)/CAST (total_cases AS float)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--Total Case VS Population


SELECT location,date,population,total_cases,  (total_cases )/(population)* 100 AS PopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
ORDER BY 1,2


--Highest Infection Rate (BY COUNTRIES)

SELECT location,population,MAX(total_cases) AS MaximumCases,  MAX((total_cases )/(population))* 100 AS HighestPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%I'
GROUP BY location,population
ORDER BY HighestPopulationInfected DESC



-- Highest Death Count

SELECT location, MAX(CAST (total_deaths as int)) AS MaximumDeath
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY MaximumDeath DESC

SELECT location, MAX(CAST (total_deaths as int)) AS MaximumDeath
FROM PortfolioProject..CovidDeaths
Where continent is  null
GROUP BY location
ORDER BY MaximumDeath DESC


--Calulation Death Count BY Continent

SELECT continent, MAX(CAST (total_deaths as int)) AS MaximumDeath
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY MaximumDeath DESC

--GLOBAL NUMBERS(EVERY DAY CASES)

SELECT date,SUM(new_cases) AS TotalNewCases,SUM (CAST (new_deaths AS int)) AS TotalDeathCases, 
			SUM (CAST (new_deaths AS int))/SUM(new_cases) * 100 AS PercentageOfDeath
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
----Group By date
--order by 1,2



-----------------------------------------------------------------------------

--JOINING COVIDDEATH AND COVID VACINATION TABLE ON TWO FACTORS LIKE LOCATION/COTINENT AND DATE

SELECT *
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVacination Vaci 
ON Death.continent= Vaci.continent 
AND Death.date= Vaci.date

--CALCULATING TOTAL PEOPLE VACCINATED

SELECT Death.date,Death.location,Death.continent,Death.population,Vaci.new_vaccinations,
		SUM( CAST(Vaci.new_vaccinations AS int)) OVER (PARTITION BY  Death.location ORDER BY Death.location, Death.date) AS total_ppl_vaccinateds
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVacination Vaci 
ON Death.location = Vaci.location
AND Death.date = Vaci.date
--WHERE Death.location like '%india%'
where Death.continent is not null
ORDER BY  Death.location, Death.date

----------------------WHERE LOCATION IS INDIA
SELECT Death.date,Death.location,Death.continent,Death.population,Vaci.new_vaccinations,
		SUM( CAST(Vaci.new_vaccinations AS int)) OVER (PARTITION BY  Death.location ORDER BY Death.location, Death.date) AS total_ppl_vaccinated 
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVacination Vaci 
ON Death.location = Vaci.location
AND Death.date = Vaci.date
WHERE Death.location like '%india%'
--where Death.continent is not null
ORDER BY  Death.location, Death.date





--CREATING CTE TO CALCULATE THE total_ppl_vaccinated Percentage

WITH VaccinatedPplPercentage(Date,location,continent,population,new_vaccination,total_ppl_vaccinated)
AS( 
SELECT Death.date,Death.location,Death.continent,Death.population,Vaci.new_vaccinations,
		SUM( CAST(Vaci.new_vaccinations AS int)) OVER (PARTITION BY  Death.location ORDER BY Death.location, Death.date) AS total_ppl_vaccinated
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVacination Vaci 
ON Death.location = Vaci.location
AND Death.date = Vaci.date
--WHERE death.location like '%india%'
where Death.continent is not null

)
SELECT *,ROUND(CAST(total_ppl_vaccinated as float)/population * 100,2) total_ppl_vaccinated_Percentage  --ROUND((total_ppl_vaccinated/population)*100,2) total_ppl_vaccinated_Percentage 
FROM VaccinatedPplPercentage


---USING TEMP TABLE TO EXECUTE THE SAME QUERY

DROP TABLE if exists  #PPLVaccinatedPercent
CREATE TABLE #PPLVaccinatedPercent
(date Date,
location nvarchar(225),
continent nvarchar(225),
population numeric,
New_Vaccination numeric,
total_ppl_vaccinated numeric)

INSERT INTO #PPLVaccinatedPercent 

SELECT Death.date,Death.location,Death.continent,Death.population,Vaci.new_vaccinations,
		SUM( CAST(Vaci.new_vaccinations AS int)) OVER (PARTITION BY  Death.location ORDER BY Death.location, Death.date) AS total_ppl_vaccinated
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVacination Vaci 
ON Death.location = Vaci.location
AND Death.date = Vaci.date
--WHERE death.location like '%india%'
where Death.continent is not null
--ORDER BY  Death.location, Death.date


SELECT *,(total_ppl_vaccinated/population) *100
FROM #PPLVaccinatedPercent


--CREATING VIEW FOR DATA VISUALIZATION
--DROP VIEW PercentPopulationVaccinated
USE PortfolioProject
GO
CREATE View PercentPopulationVaccinated AS
SELECT Death.date,Death.location,Death.continent,Death.population,Vaci.new_vaccinations,
		SUM( CAST(Vaci.new_vaccinations AS int)) OVER (PARTITION BY  Death.location ORDER BY Death.location, Death.date) AS total_ppl_vaccinated
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVacination Vaci 
ON Death.location = Vaci.location
AND Death.date = Vaci.date
where Death.continent is not null
--ORDER BY  Death.location, Death.date
Select * From PercentPopulationVaccinated
