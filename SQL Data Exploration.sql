


--Task(1) Covid-19 Total Cases Vs Total Deaths by Country?
        Select Location,date,Total_cases,Total_deaths, (total_deaths/total_cases)*100 as totaldeathpercase
        From Covid_deaths
        Where continent is not Null
        Order By 1,2;

--Task(2) Likelyhood of dying from Covid-19 in Canada if you contract covid-19 virus?
        Select Location,date,Total_cases,Total_deaths, (total_deaths/total_cases)*100 as totaldeathpercase
        From Covid_deaths
	Where location ='Canada'
	Order By 1,2;

--Task(3) Show Total Covid-19 Cases Per Population.
       Select  Location,date,Total_cases,population, (total_cases/population)*100 As Caseperpopulation
       From Covid_deaths
       Where location='Canada'
       Order By 1,2;

  --Task(4) List the Countries with Highest Infection Rate Compared to Population.
       Select  Location,population,Max(Total_cases) As highestinfectionrate, Max((total_cases/population)*100) As Percentagepopulationinfected
       From Covid_deaths
       Where continent is not Null
       Group By Location,population
       Order By Percentagepopulationinfected Desc

--Task(4) Showing Countries with Highest Death Count Per Population?
      Select  Location, Max(Cast(total_deaths As int)) As highestdeaths
      From Covid_deaths
      Where continent is not Null
      Group By Location
      Order By highestdeaths Desc

--Task(5) Showing Countinents with Highest Death Count Per Population?
      Select location, Max(Cast(total_deaths As int)) As DeathTollbyContinent
      From Covid_deaths
      Where continent is Null
      And location not in ('world','European union','International')
      Group By location
      Order By DeathTollbyContinent Desc;
   
--Task(6) Global Covid-19 Cases,Deaths and Death Percentage. 
      Select SUM(new_cases) As total_cases,SUM(cast(new_deaths As int)) As total_deaths,SUM(cast(new_deaths As int))/SUM (New_cases)*100 As deathpercentage
      From Covid_deaths
      Where continent is not Null

--Task(7) Total Population vs Vaccinations by Country
      SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
      FROM  covid_deaths cd
      Join covid_vac    cv
      On cd.location=cv.location
      And cd.date  =cv.date
      Where cd.continent is not Null
      Order By 2,3;
   
--Task(8) Rolling Up Countiries Vaccinations (Updated for Current Day i.e July07/2021)
       SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(convert(int,cv.new_vaccinations)) over(partition By cd.location 
       Order By cd.location,cd.date)As Rollingupcountriesvac 
       FROM  covid_deaths  cd
       Join covid_vac    cv
       On cd.location=cv.location
       And cd.date  =cv.date
       Where cd.continent is not Null
       Order By 2,3;

--Task(9) Rolling Vaccination to Population Percentage.
       WITH popvsvac (Continent,Location,Date,Population,new_vaccinations,Rollingupcountriesvac) 
       As(
       SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(convert(int,cv.new_vaccinations)) over(partition By cd.location 
       Order By cd.location,cd.date)As Rollingupcountriesvac 
       FROM  covid_deaths  cd                                                  
       Join covid_vac     cv
       On cd.location=cv.location
       And cd.date  =cv.date
       Where cd.continent is not Null
       )                      
       Select * ,(Rollingupcountriesvac/population)*100  As percentagepeoplevaccinated          
       From Popvsvac                                                 
   
 
  
