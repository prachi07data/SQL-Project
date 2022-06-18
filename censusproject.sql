select *from [census project].dbo.data1
select *from [census project].dbo.data2


select count(*) from [census project]..data1
select count(*) from [census project]..data2

----dataset for jharkhand and bihar
select *from [census project].dbo.data1 where state in('jharkhand','Bihar')

-------population of india
select sum(population) as totalpopulation from [census project].dbo.data2
---avg growth
select AVG(growth)*100 as avggrowth from [census project]..Data1

select state, AVG(growth)*100 as avggrowth from [census project]..Data1 group by state

--avg sex ratio--

select state, round(AVG(sex_ratio),0) as avgsex_ratio from [census project]..Data1 group by state

----arranging data into descending order
select state, round(AVG(sex_ratio),0) as avgsex_ratio from [census project]..Data1 group by state order by  avgsex_ratio desc
---avg literacy rate--
select state, round(AVG(literacy),0) as avgliteracyrates from [census project]..Data1 group by state order by  avgliteracyrates desc
------->90------
select state, round(AVG(literacy),0) as avgliteracyrates from [census project]..Data1 group by state  having round(AVG(literacy),0)>90 order by  avgliteracyrates desc

top 3 states  which have develops highest growtH
select TOP 3 state, AVG(GROWTH)*100 as avgGR_ratio from [census project]..Data1 group by state order by  avgGR_ratio desc

---BOTTOM 3 SHOWING LOWEST SEX RATIO
SELECT TOP 3 STATE, ROUND(AVG(SEX_RATIO),0) AS AVGSEXRAT FROM [census project]..Data1 GROUP BY STATE ORDER BY AVGSEXRAT ASC
--------TOP 3 AND BOTTOM 3 SHOWING LITERACCY RATES-
---- FIRST CREATE TEMPORARY TABLE--

DROP TABLE IF EXISTS #topstates
CREATE TABLE #TOPSTATES
(STATE NVARCHAR(255),
TOPSTATES  FLOAT
)

insert into #topstates
SELECT TOP 3 STATE, ROUND(AVG(literacy),0) AS AVGliteracy FROM [census project]..Data1 GROUP BY STATE ORDER BY AVGliteracy DESC

SELECT *FROM #TOPSTATES ORDER BY #TOPSTATES.TOPSTATES DESC



DROP TABLE IF EXISTS #BOTTOMstates
CREATE TABLE #BOTTOMstates
(STATE NVARCHAR(255),
BOTTOMstates  FLOAT
)

insert into #BOTTOMstates
SELECT TOP 3 STATE, ROUND(AVG(literacy),0) AS AVGliteracy FROM [census project]..Data1 GROUP BY STATE ORDER BY AVGliteracy ASC

SELECT *FROM #BOTTOMstates



---UNION OPERATOR
SELECT * FROM (
SELECT TOP 3 STATE, ROUND(AVG(literacy),0) AS AVGliteracy FROM [census project]..Data1 GROUP BY STATE ORDER BY AVGliteracy DESC) A
UNION
SELECT * FROM (
SELECT TOP 3 STATE, ROUND(AVG(literacy),0) AS AVGliteracy FROM [census project]..Data1 GROUP BY STATE ORDER BY AVGliteracy ASC) B


----STATES STARTING WITH LETTER A

-----states end d start with a with letter--


select distinct state from [census project]..Data1 where lower(state) like 'a%' or lower(state) like '%d'


select distinct state from [census project]..Data1 where lower(state) like 'a%' and lower(state) like '%m'

select  distinct state from [census project]..Data1 where lower( state) like 'u%' and lower( state) like '%d'

-------JOIN BOTH TABLES------
SELECT a.DISTRICT,a.STATE,a.SEX_RATIO,b.POPULATION FROM [census project]..Data1 as a inner join [census project]..data2 b on a.District=b.district


---calculation number of males and females

select c.district,c.state,round(c.population/(c.sex_ratio+1),0) as males,round((c.population*c.Sex_Ratio)/(c.sex_ratio+1),0) as females from 
(SELECT a.DISTRICT,a.STATE,a.SEX_RATIO,b.POPULATION FROM [census project]..Data1 a inner join [census project]..data2 b on a.District=b.district) c

--------group by state

select d.state,sum(d.males) as total_males,sum(d.females) as total_females from
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) as males,round((c.population*c.Sex_Ratio)/(c.sex_ratio+1),0) as females from 
(SELECT a.DISTRICT,a.STATE,a.SEX_RATIO,b.POPULATION FROM [census project]..Data1 a inner join [census project]..data2 b on a.District=b.district) c)d

group by d.state


----total literacy rates--
SELECT a.DISTRICT,a.STATE,a.Literacy as lit_ratio,b.POPULATION FROM [census project]..Data1 a inner join [census project]..data2 b on a.District=b.district

select D.district,D.state,ROUND(D.lit_ratio*D.population,0) as lit_people,ROUND((1-D.lit_ratio)*D.population,0) AS ILLIT_PEOPPLE FROM
(SELECT a.district,a.state,a.Literacy/100 as lit_ratio,b.population from [census project]..Data1 as a inner join [census project]..data2 as b on a.district=b.district)d

-----GROUP BY STATES
select c.state,sum(c.lit_people) as litt,SUM(c.ILLIT_PEOPPLE) as illlittt from
(select D.district,D.state,ROUND(D.lit_ratio*D.population,0) as lit_people,ROUND((1-D.lit_ratio)*D.population,0) AS ILLIT_PEOPPLE FROM
(SELECT a.district,a.state,a.Literacy/100 as lit_ratio,b.population from [census project]..Data1 as a inner join [census project]..data2 as b on a.district=b.district)d)c
group by c.State


---we want pop of previous census

select a.district,a.state,a.growth,b.population from [census project]..Data1 as a inner join [census project]..data2 as b on a.district=b.district

select e.state, e.district, round(e.population/(1+e.growth),0) as past_pop,e.population from 
(select a.district,a.state,a.growth,b.population from [census project]..Data1 as a inner join [census project]..data2 as b on a.district=b.District) e
---group by state---
select f.state,sum(f.past_pop) as total_past_pop,sum(f.population) as current_pop from 
(select e.state,e.district,round(e.population/(1+e.growth),0) as past_pop,e.population from 
(select a.district,a.state,a.growth,b.population from [census project]..Data1 as a inner join [census project]..data2 as b on a.district=b.District) e)f
group by f.state

--total states pop
select sum(g.total_past_pop) as tota_past_popu,sum(g.current_pop) from (
select f.state,sum(f.past_pop) as total_past_pop,sum(f.population) as current_pop from 
(select e.state,e.district,round(e.population/(1+e.growth),0) as past_pop,e.population from 
(select a.district,a.state,a.growth,b.population from [census project]..Data1 as a inner join [census project]..data2 as b on a.district=b.District) e)f
group by f.state)g


---area VS POP

select SUM(AREA_KM2) AS TOTA_AREA FROM [census project]..data2