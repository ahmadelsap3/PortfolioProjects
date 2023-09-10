--select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
from PortfolioProject..CovidVaccinations$
order by 3,4

select location, date, total_cases_per_million, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths

select location, date, total_deaths, new_deaths
from PortfolioProject..CovidDeaths$
where location like '%Egypt%'
order by 1,2

--looking at the total cases vs population

select location, date, total_tests, population, (total_tests/population)*100 as TestPerPopulationPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Egypt%'
order by 1,2




--showing countries with highest death count per population

select location,MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Egypt%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent

select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Egypt%'
where continent is not null
Group by location
order by TotalDeathCount desc

--showing the continents with the highest death count per popoulation

select continent,MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Egypt%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--looking at total population vs vaccinations
--USE CTE
with PopvsVac(continent, location, date, population,New_vaccinations, RollingPeopleVaccinated)
as
(
select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(ISNULL(cast(vac.new_vaccinations as bigint),0)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from
PortfolioProject..CovidDeaths$ dea
join
PortfolioProject..CovidVaccinations$ vac
	ON
	dea.location = vac.location
	and dea.date = vac.date
where
dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population) *100
from PopvsVac

--TEMP TABLE
drop table if exists #Percentpoulationvaccinated
create table #Percentpoulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinatons numeric,
RollingPeopleVaccinated numeric
)
insert into #Percentpoulationvaccinated
select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(ISNULL(cast(vac.new_vaccinations as bigint),0)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from
PortfolioProject..CovidDeaths$ dea
join
PortfolioProject..CovidVaccinations$ vac
	ON
	dea.location = vac.location
	and dea.date = vac.date
--where
--dea.continent is not null
select * , (RollingPeopleVaccinated/population)*100
from #Percentpoulationvaccinated


--creating views to store data fol later visualizations

create view PPV as
select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(ISNULL(cast(vac.new_vaccinations as bigint),0)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from
PortfolioProject..CovidDeaths$ dea
join
PortfolioProject..CovidVaccinations$ vac
	ON
	dea.location = vac.location
	and dea.date = vac.date
where
dea.continent is not null
--order by 2,3