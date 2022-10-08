select * from Projects.dbo.censusdata1;

select * from Projects.dbo.censusdata2;

-- Finding number of rows 

select count(*) from Projects.dbo.censusdata1;

select count(*) from Projects.dbo.censusdata2;

-- Finding data for particular states

select * from Projects.dbo.censusdata1
where State in ('Tamil Nadu','Kerala');

-- Finding total population 

select sum(Population) as TotalPopulation from Projects.dbo.censusdata2;

-- Finding Average Population Growth

select avg(Growth)*100 as AvgGrowth from Projects.dbo.censusdata1;

-- Finding State's Average Population Growth

select State, avg(Growth)*100 as AvgGrowth 
from Projects.dbo.censusdata1
group by State;

-- Finding AverageSex Ratio

select State , round(avg(Sex_Ratio),0) as AvgSexRatio 
from Projects.dbo.censusdata1
group by State
order by AvgSexRatio desc;

-- Finding average literacy rate & displaying states which has more than 80.

select State , round(avg(Literacy),0) as AvgLiteracyRate 
from Projects.dbo.censusdata1
group by State
having round(avg(Literacy),0) > 80
order by AvgLiteracyRate desc;

-- Finding top 3 states having Literacy Rate & Sex Ratio & Growth

select top 3 State , round(avg(Sex_Ratio),0) as AvgSexRatio 
from Projects.dbo.censusdata1
group by State
order by AvgSexRatio desc;

select top 3 State , round(avg(Literacy),0) as AvgLiteracy
from Projects.dbo.censusdata1
group by State
order by AvgLiteracy desc;

select top 3 State, avg(Growth)*100 as AvgGrowth 
from Projects.dbo.censusdata1
group by State
order by AvgGrowth desc;


-- Finding bottom 5 states having Literacy Rate & Sex Ratio & Growth

select top 5 State , round(avg(Sex_Ratio),0) as AvgSexRatio 
from Projects.dbo.censusdata1
group by State
order by AvgSexRatio;

select top 5 State , round(avg(Literacy),0) as AvgLiteracy
from Projects.dbo.censusdata1
group by State
order by AvgLiteracy;

select top 5 State, avg(Growth)*100 as AvgGrowth 
from Projects.dbo.censusdata1
group by State
order by AvgGrowth;

-- Top & Bottom 3 states using CTE

drop table if exists #TopStates
create table #TopStates
(state varchar(255),
	literacyrate float)

insert into #TopStates
select State , round(avg(Literacy),0) as AvgLiteracy
from Projects.dbo.censusdata1
group by State
order by AvgLiteracy;

select top 5 * from #TopStates 
order by literacyrate desc;

select top 5 * from #TopStates 
order by literacyrate;

-- Using UNION Operator combining two data

select * from
(select top 5 * from #TopStates 
order by literacyrate desc) a

UNION

select * from
(select top 5 * from #TopStates 
order by literacyrate) b
order by literacyrate;


-- Finding data for states starting with T

select * from Projects.dbo.censusdata1
where State like 'T%'

-- Finding data for states starting with M & ending with A

select * from Projects.dbo.censusdata1
where State like 'M%a'


-- Joining both tables

select a.District, a.State , a.Sex_Ratio , b.Population 
from Projects.dbo.censusdata1 a
join Projects.dbo.censusdata2 b
on a.District = b.District

--Finding males & females population count

select c.District, c.State , (c.Population/(c.Sex_Ratio/1000)+1) as MaleCount , (c.Population*(c.Sex_Ratio/1000)/(c.Sex_Ratio/1000)+1) as FemaleCount
from 
(select a.District, a.State , a.Sex_Ratio , b.Population 
from Projects.dbo.censusdata1 a
join Projects.dbo.censusdata2 b
on a.District = b.District) c


select d.State, sum(d.MaleCount) as TotalMale , sum(d.FemaleCount) as TotalFemale from
(select c.District, c.State , (c.Population/(c.Sex_Ratio/1000)+1) as MaleCount , ((c.Population*(c.Sex_Ratio/1000))/(c.Sex_Ratio/1000)+1) as FemaleCount
from 
(select a.District, a.State , a.Sex_Ratio , b.Population 
from Projects.dbo.censusdata1 a
join Projects.dbo.censusdata2 b
on a.District = b.District) c)d
group by d.State;


-- Finding Literaacy people count


select d.State , sum(d.LiterateCount) as TotalLiterateCount , sum(d.IlliterateCount) as TotalIlliterateCount from
(select c.State, c.District , round((c.LR*c.Population),0) as LiterateCount , round(((1 - c.LR)*c.Population),0) as IlliterateCount from 
(select a.State, b.District, (a.Literacy/100) as LR, b.Population
from Projects.dbo.censusdata1 a
join Projects.dbo.censusdata2 b
on a.District = b.District) c) d
group by d.State;

-- Finding Population in previous census

select d.State , sum(d.PreviousCensusCount) as TotalPreviousCensusCount , sum(d.CurrentCensusCount) as TotalCurrentCensusCount from
(select c.State, c.District , round((c.Population/(1+c.Growth)),0) as PreviousCensusCount , c.Population as CurrentCensusCount from 
(select a.State, b.District, a.Growth, b.Population
from Projects.dbo.censusdata1 a
join Projects.dbo.censusdata2 b
on a.District = b.District) c) d
group by d.State;

-- Finding Average Population Desnity for previous Census vs Current Census

select d.State , avg(d.PreviousPopulationDensity) as TotalPreviousCensusCount , avg(d.CurrentPopulationDensity) as TotalCurrentCensusCount from
(select c.State, c.District , (round((c.Population/(1+c.Growth)),0)/c.Area_km2) as PreviousPopulationDensity , (c.Population/c.Area_km2) as CurrentPopulationDensity from 
(select a.State, b.District, b.Area_km2, b.Population, a.Growth
from Projects.dbo.censusdata1 a
join Projects.dbo.censusdata2 b
on a.District = b.District) c) d
group by d.State;


-- using Window functions

select a.* from 
(select District, State, Literacy , 
RANK() over(partition by State order by Literacy desc) as LRank
from Projects.dbo.censusdata1) a
where a.LRank in (1,2,3)
order by State;



