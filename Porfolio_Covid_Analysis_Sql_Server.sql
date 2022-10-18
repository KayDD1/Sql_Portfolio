select *
from PorfolioCovidSql..CovidDeaths$
where continent is not null
order by 3, 4

--select *
--from PorfolioCovidSql..CovidVacinnations$
--order by 3, 4

--Select Data/Columns to be used for analysis

Select location, date, total_cases, new_cases, total_deaths, population
From PorfolioCovidSql..CovidDeaths$
Where continent IS NOT NULL
Order By 1, 2

-- Inspecting Total Cases Versus Total Deaths

-- A likelihood of dying from covid by countries

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioCovidSql..CovidDeaths$
Where location like '%Nigeria%' and continent IS NOT NULL
Order By 1, 2 desc

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioCovidSql..CovidDeaths$
Where location like '%United Kingdom%' and continent IS NOT NULL
Order By 1, 2

-- Analysing Total Cases By Population
-- Shows the percentage of population infected

Select location, date, population, total_cases,  (total_cases / population)*100 as InfectedPopulationPercentage
From PorfolioCovidSql..CovidDeaths$
Where continent IS NOT NULL
--Where location like '%United Kingdom%' 
Order By 1, 2

-- Inspecting Countries with highest Infection Rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases / population))*100 as InfectedPopulationPercentage
From PorfolioCovidSql..CovidDeaths$
Where continent IS NOT NULL
--Where location like '%United Kingdom%' 
Group By location, population
Order By InfectedPopulationPercentage desc

-- Countries with the highest number of Deaths Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathsCount
From PorfolioCovidSql..CovidDeaths$
Where continent is not null
Group By Location
Order By TotalDeathsCount desc

-- Analysing Data by Continent

--This is the right way to select the continents with total deaths count

/*
Select location, Max(cast(total_deaths as int)) as TotalDeathsCount
From PorfolioCovidSql..CovidDeaths$
Where continent is null
Group By location
Order By TotalDeathsCount desc
*/

Select continent, Max(cast(total_deaths as int)) as TotalDeathsCount
From PorfolioCovidSql..CovidDeaths$
Where continent is not null
Group By continent
Order By TotalDeathsCount desc

-- Global Analysis

--Percentage of Global Deaths per New Cases on a single Date

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalDeathPercentage
From PorfolioCovidSql..CovidDeaths$
Where continent IS NOT NULL
Group By date
Order By 1, 2

-- Percentage of Global Deaths per New Covid Infection Cases

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalDeathPercentage
From PorfolioCovidSql..CovidDeaths$
Where continent IS NOT NULL
Order By 1, 2

-- Global : Total Population Vs Vacinnation

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioCovidSql..CovidDeaths$ dea
join PorfolioCovidSql..CovidVacinnations$ vac
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent IS NOT NULL
Order By 2, 3

-- Use CTE to analyse RollingPeopleVacinnated with total population
--Note the number of columns must be equal in the query and cte specification

With PopvsVac (continent, location, date, population, new_vacinnations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioCovidSql..CovidDeaths$ dea
join PorfolioCovidSql..CovidVacinnations$ vac
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order By 2, 3
)

Select *, (RollingPeopleVaccinated/population)* 100 as PercentagePopVacinated
From PopvsVac

-- Using Temp Table


Drop Table IF exists #PercentPopulationVacinnated
Create Table #PercentPopulationVacinnated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinnations numeric,
RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVacinnated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioCovidSql..CovidDeaths$ dea
join PorfolioCovidSql..CovidVacinnations$ vac
	ON dea.location = vac.location and dea.date = vac.date
--Where dea.continent IS NOT NULL
--Order By 2, 3

Select *, (RollingPeopleVaccinated/population)* 100 as PercentagePopVacinated
From #PercentPopulationVacinnated

-- Create View to store for data visualizations

Create View PercentPopulationVacinnated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioCovidSql..CovidDeaths$ dea
join PorfolioCovidSql..CovidVacinnations$ vac
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent IS NOT NULL

Select *
From PercentPopulationVacinnated
