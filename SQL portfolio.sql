select 
	Location, 
	Date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from [Portfolio Project]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
select 
	Location, 
	Date, 
	total_cases, 
	total_deaths,
	round((total_deaths/total_cases)*100,2) as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location = 'united states'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population contracted COVID
select 
	Location, 
	Date, 
	total_cases, 
	population, 
	round((total_cases/population)*100,2) as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
where location = 'united states'
and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Rate per Population

Select 
	Location, 
	MAX(cast (total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Break down by Continent 
-- Showing contintents with the highest death count per population
Select 
	continent, 
	MAX(cast (total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is NOT null 
Group by continent
order by TotalDeathCount desc

-- Global numbers
Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null 
order by 1,2

--Looking at Total Population vs Vaccinations

Select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingVacCount
from [Portfolio Project].. CovidDeaths d 
join [Portfolio Project]..CovidVaccinations v on d.location = v.location 
	and d.date = v.date
where d.continent is not null 
order by 2,3

	--Using a CTE
	with Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as 
		(Select 
		d.continent, 
		d.location, 
		d.date, 
		d.population, 
		v.new_vaccinations, 
		sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingVacCount
	from [Portfolio Project].. CovidDeaths d 
	join [Portfolio Project]..CovidVaccinations v on d.location = v.location 
		and d.date = v.date
	where d.continent is not null 
	)

	select *, round((RollingPeopleVaccinated/population)*100,2) PercentVaccinated
	from Popvsvac

	--Using Temp table 
	DROP Table if exists #PercentPopulationVaccinated
	Select 
		d.continent, 
		d.location,
		d.date,
		d.population, 
		v.new_vaccinations,
		SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
	into #PercentPopulationVaccinated
	From [Portfolio Project]..CovidDeaths d
	Join [Portfolio Project]..CovidVaccinations v
		On d.location = v.location
		and d.date = v.date

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

--create views for later visuals

Create view PercentPopulationVaccinated as 
	Select 
		d.continent, 
		d.location,
		d.date,
		d.population, 
		v.new_vaccinations,
		SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
	From [Portfolio Project]..CovidDeaths d
	Join [Portfolio Project]..CovidVaccinations v
		On d.location = v.location
		and d.date = v.date
	where d.continent is not null 

Select * from PercentPopulationVaccinated where location = 'United States'