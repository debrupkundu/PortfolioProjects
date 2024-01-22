select*
from Portfolio_project..CovidDeaths$
where continent is not null
order by 3,4

--select*
--from Portfolio_project..CovidVaccinations$
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_project..CovidDeaths$
order by 1,2 

--looking at total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from Portfolio_project..CovidDeaths$
where location like '%india'
order by 1,2 

--looking at total cases vs population

select location,date,total_cases,population,(total_cases/population)*100 as 
from Portfolio_project..CovidDeaths$
where location like '%india'
order by 1,2 

--looking at countries with highest infection rate compared to population

select location,population,MAX(total_cases) as highestInfectionCount,MAX((total_cases/population))*100 as percentPopulationInfected
from Portfolio_project..CovidDeaths$
--where location like '%india'
group by population,location
order by percentPopulationInfected desc

--showing countries with highest death count per population

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_project..CovidDeaths$
--where location like '%india'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select date,sum(cast(new_cases as int)) as total_cases,sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths$
where continent is not null
group by date
order by 1,2 

--total cases and total_deaths across the world

select sum(cast(new_cases as int)) as total_cases,sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths$
where continent is not null
order by 1,2 

--looking at total population vs vaccinations


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER( PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_project..CovidDeaths$ dea
join Portfolio_project..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using a temp Table to find vaccinated population percentage %

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER( PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_project..CovidDeaths$ dea
join Portfolio_project..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100 as TotalVaccinationPercentage
from #PercentPopulationVaccinated

--Creating views to store data for later visualizations

Create View  PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER( PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Portfolio_project..CovidDeaths$ dea
join Portfolio_project..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null


select* 
from  PercentPopulationVaccinated