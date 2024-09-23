--SELECT * FROM covidvaccinations
--ORDER BY 3, 4 

--Select daa that we are going to be using

SELECT locations, date_cv, total_cases, new_cases, total_deaths, population
FROM coviddeath
ORDER BY 1,2;

--Looking at the total cases vs total deaths

--likelihood of dying in Kazakhstan if caught the Covid
SELECT locations, date_cv, total_cases, total_deaths, (total_deaths :: NUMERIC /total_cases :: NUMERIC)* 100 AS death_rate 
FROM coviddeath
where locations like '%Kazakh%'
ORDER BY 1,2;

--looking at he total cases and population

SELECT locations, date_cv, total_cases, population, (total_cases :: NUMERIC /population :: NUMERIC)* 100 AS CovidPercentageByPopulation 
FROM coviddeath
where locations like '%Kazakh%'
ORDER BY 1,2;

--looking at countries with the highest infection rate compared to population

SELECT locations, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases :: NUMERIC /population :: NUMERIC))* 100 AS MaxInfectionPercentageByPopulation 
FROM coviddeath
GROUP BY locations, population
ORDER BY MaxInfectionPercentageByPopulation DESC;

--Looking at the countries with the highest death rate

SELECT locations, MAX(total_deaths) AS HighestDeathsCount, population, MAX((total_deaths :: NUMERIC /population :: NUMERIC))* 100 AS MaxDeathsPercentageByPopulation 
FROM coviddeath
WHERE continent is not null and total_deaths is not null
GROUP BY locations, population
ORDER BY HighestDeathsCount DESC;

--Looking at the continents with the highest death rate

SELECT locations, MAX(total_deaths) AS HighestDeathsCount
FROM coviddeath
WHERE continent is  null 
GROUP BY locations
ORDER BY HighestDeathsCount DESC;

--showing the continents with the highest death count

SELECT continent, MAX(total_deaths) AS HighestDeathsCount
FROM coviddeath
WHERE continent is not null 
GROUP BY continent
ORDER BY HighestDeathsCount DESC;


--Global numbers per day

SELECT date_cv, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths :: NUMERIC) *100 / SUM(new_cases :: NUMERIC) AS GlobalDeathsRate
FROM coviddeath
WHERE continent is not null
GROUP BY date_cv
ORDER BY 1,2;

--Global numbers in total

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths :: NUMERIC) *100 / SUM(new_cases :: NUMERIC) AS GlobalDeathsRate
FROM coviddeath
WHERE continent is not null
ORDER BY 1,2;
--Overalll across the world death percantage of dying from covid is 2.11%

--Looking at Total Population vs Vaccinations
--USE CTE
with PopvsVac (Continent, Locations, Date_cv, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.locations, dea.date_cv, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.locations ORDER BY dea.locations, dea.date_cv)
FROM coviddeath dea
JOIN Covidvaccinations vac
	ON dea.locations = vac.location_cv
	and dea.date_cv = vac.date_cvv
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated :: NUMERIC / population :: NUMERIC)*100 AS VaccinationRate
From PopvsVac

--TEMP TABLE
Create table GlobalVacRate
(continent varchar(125),
 locaton varchar(125),
 date date,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 
)

INSERT INTO GlobalVacRate
SELECT dea.continent, dea.locations, dea.date_cv, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.locations ORDER BY dea.locations, dea.date_cv)
FROM coviddeath dea
JOIN Covidvaccinations vac
	ON dea.locations = vac.location_cv
	and dea.date_cv = vac.date_cvv
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated :: NUMERIC / population :: NUMERIC)*100 AS VaccinationRate
From GlobalVacRate

--Creating the view to store data for the later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.locations, dea.date_cv, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.locations ORDER BY dea.locations, dea.date_cv)
FROM coviddeath dea
JOIN Covidvaccinations vac
	ON dea.locations = vac.location_cv
	and dea.date_cv = vac.date_cvv
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated
