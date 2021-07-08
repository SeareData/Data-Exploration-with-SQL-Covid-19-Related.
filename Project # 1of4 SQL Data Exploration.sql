
select location,date,total_cases_per_million,new_cases,total_deaths,population
from Covid_deaths
order by 1,2




select location,date,total_cases,new_cases,total_deaths,population
from Covid_deaths
order by 1,2


--Looking at Total Cases Vs Total Deaths.
select Location,date,Total_cases,Total_deaths, (total_deaths/total_cases)*100 as totaldeathpercase
from Covid_deaths
where continent is not null
 order by 1,2;

--Show Likelyhood of dying from Covid in Canada if you contract covid in Canada.

    select Location,date,Total_cases,Total_deaths, (total_deaths/total_cases)*100 as totaldeathpercase
    from Covid_deaths
	where location ='Canada'
	order by 1,2;

   --Show total Cases Per Population.
   --Shows what percentage of population contracted Covid.
   Select  Location,date,Total_cases,population, (total_cases/population)*100 as Caseperpopulation
   From Covid_deaths
   where location='Canada'
   order by 1,2;

  --List the Countries with Highest Infection Rate Compared to Population.
   
   Select  Location,population,Max(Total_cases) as highestinfectionrate, Max((total_cases/population)*100) as Percentagepopulationinfected
   From Covid_deaths
   where continent is not null
   group by Location,population
   order by Percentagepopulationinfected desc

   --showing countries with highest death count per population?

   Select  Location, Max(Cast(total_deaths as int)) as highestdeaths
   From Covid_deaths
   where continent is not null
   group by Location
   order by highestdeaths desc

   --LETS BREAK THINGS DOWN BY CONTINENT
   ----showing countinents with highest death count per population?
   Select location, Max(Cast(total_deaths as int)) as highestdeaths
   From Covid_deaths
   where continent is  null
   group by location
   order by highestdeaths desc

   --Global Numbers
   select date, SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast
   (new_deaths as int))/SUM (New_cases)*100 as deathpercentage
   from Covid_deaths
   where continent is not null
   Group by date
   order by 1,2

	--Case # 2 If We remove the date column, we can check up to todays(July 6th 2021) total cases and deaths.
;  
   select SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast
   (new_deaths as int))/SUM (New_cases)*100 as deathpercentage
   from Covid_deaths
   where continent is not null

  -- LET'S NOW SEE THE COVID_VAC TABLE
   select * 
   From Covid_vac

   --LET'S JOIN COVID_VAC TABLE WITH COVID_DEATHS TABLE AND SEE TOTAL POPULATION VS VACCINATIONS
   SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
   FROM  covid_deaths cd
   join covid_vac    cv
   on cd.location=cv.location
   and cd.date  =cv.date
    where cd.continent is not null
   order by 2,3;
   
   --The PARTITION BY clause is a subclause of the OVER clause. The PARTITION BY clause divides a query’s result set into partitions. The window function is operated on each partition 
   ---separately and recalculate for each partition.
   --The following shows the syntax of the PARTITION BY clause:
   ---window_function ( expression ) OVER (
   --- PARTITION BY expression1, expression2, ...
    ---order_clause
    ---frame_clause
	---The group by function ---The GROUP BY clause reduces the number of rows returned by rolling them up and calculating the sums or averages for each group.but Partition by clause don't 



  -- Rolling up Countiries Vaccinations (Updated for current day)
   SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,
   cd.date)as Rollingupcountriesvac --we used here Partition by clause 
   FROM  covid_deaths cd
   join covid_vac    cv
   on cd.location=cv.location
   and cd.date  =cv.date
    where cd.continent is not null
   order by 2,3;

  -- Portion of people vaccinated in a country
              -- Note this query will fail because we don't have a table with Rollingupcountriesvac.
   SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,
   cd.date)as Rollingupcountriesvac, (Rollingupcountriesvac/population)*100 --the last one will not work because i don't have a table with column Rollingupcontriesvac,so I have to 
   --make a temporary table..or .CTE.)
   FROM  covid_deaths cd
   join covid_vac    cv
   on cd.location=cv.location
   and cd.date  =cv.date
    where cd.continent is not null
   order by 2,3;

 --Let's first use CTE to calculate percentage of population vaccinated per population (PopvsVac)

   WITH popvsvac (Continent,Location,Date,Population,new_vaccinations,Rollingupcountriesvac) --CTE column count should be the same as the subquery.
   as (
   SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,
   cd.date)as Rollingupcountriesvac 
   FROM  covid_deaths  cd                                                  
   join covid_vac     cv
   on cd.location=cv.location
   and cd.date  =cv.date
    where cd.continent is not null
   )                      
   Select * ,(Rollingupcountriesvac/population)*100  as percentagepeoplevaccinated          --we add this query to view the result otherwise nothing will be displayed and we can add 
               From Popvsvac                                  -- columns we want to add by adding comma after *               
   
   ---IF WE RUN THE ABOVE QUERY WE WILL GET THE ROLLING VACCINATION TO POPULATION PERCENTAGE.
   --ASIGNMENT TO BE DONE: FIND THE MAXIMUM OR THE CURRENT VACCINATION TO POPULATION PERCENTAGE BY USING MAX AGGREGATE FUNCTION.
   
   
     ----Temporary Tables.
	 Drop table if exists #Percentagepeoplevaccinated --We do this 'drop table' funcion because once you want to do any alterations like for example commenting out the where clause below,you will be able to run the query as much as you want.
	 Create Table #Percentagepeoplevaccinated
	 ( Continent nvarchar(255),
	 Location nvarchar(255),
	 Date datetime,
	 Population numeric,
	 New_vaccinations numeric,
	 Rollingupcountriesvac numeric
	 )
	 Insert into #Percentagepeoplevaccinated
	 SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,
     cd.date)as Rollingupcountriesvac --we used here Partition by clause 
     FROM  covid_deaths cd
     join covid_vac    cv
     on cd.location=cv.location
     and cd.date  =cv.date
     --where cd.continent is not null --when we commented out this one we saw a message that says "There is already an object named '#Percentagepeoplevaccinated' in the database. but when we added the drop function above it goes through." Please read the comment above to understand the reason behind this.
     order by 2,3;
	 Select * ,(Rollingupcountriesvac/population)*100  as percentagepeoplevaccinated --we add this query to view the result otherwise nothing will be displayed and we can add 
      From  #Percentagepeoplevaccinated 
	  
	 -- VIEW: 
	 --Asignment -Please Make viwes as much as you can for your Portofilio. You can start from Global Numbers.
	 --Let's Create view to store data for later visualization.
	
	 Create View Percentagepeoplevaccinated 
	 AS
	 SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,
     cd.date)as Rollingupcountriesvac --we used here Partition by clause 
     FROM  covid_deaths cd
     join covid_vac    cv
     on cd.location=cv.location
     and cd.date  =cv.date
     where cd.continent is not null
     --order by 2,3;

	 --In order to see the out put of the VIEW you made, Use the SELECT statement.
	 select * from Percentagepeoplevaccinated
	 --Making Views help us to make our visualization in TABLEAU Easy. So it is a good habit to have a lot of views created.We can connect this one with Tableau Public.
	 --Next step will be save this work and upload it to gethub
	  