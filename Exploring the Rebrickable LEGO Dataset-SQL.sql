--Create the view query
--join the sets and theme tables on the themes.id and sets.theme_id
--join the themes table to itself in order to query both the theme name and the parent theme name.
CREATE VIEW dbo.analytics_main AS 
SELECT 
	s.set_num,
	s.name AS set_name,
	s.year,
	s.theme_id,
	CAST(s.num_parts AS numeric) AS num_parts,
	
	t.name AS theme_name,
	t.parent_id,

	p.name AS parent_theme_name

FROM dbo.sets AS s
LEFT JOIN dbo.themes AS t
ON s.theme_id = t.id
LEFT JOIN dbo.themes p
ON t.parent_id=p.id
go


--Number of Parts per Theme
SELECT 
	theme_name,
	SUM(num_parts) AS total_number_parts
FROM [Rebrickable].[dbo].[analytics_main]
GROUP BY theme_name
ORDER BY total_number_parts DESC
GO


--Number of Parts per Year
SELECT 
	year,
	SUM(num_parts) AS total_number_parts
FROM [Rebrickable].[dbo].[analytics_main]
GROUP BY year
ORDER BY total_number_parts DESC
GO


--Number of Sets per Century
SELECT 
	Century,
	COUNT(set_num) AS total_number_sets

FROM [Rebrickable].[dbo].[analytics_main]
GROUP BY Century
ORDER BY total_number_sets DESC
GO


--Percentage of trains themed sets released in the 21st Century
;WITH CTE AS(
SELECT 
	Century, 
	theme_name,
	COUNT(set_num) AS total_set_number
FROM [Rebrickable].[dbo].[analytics_main]
WHERE Century ='21st_Century' 	
GROUP BY Century,theme_name
) 
SELECT SUM(total_set_number) AS Number_of_Trains_Sets, SUM(percentage_of_total) AS PercentageOfTotal
FROM(
SELECT 
	Century, 
	theme_name,
	total_set_number,
	SUM(total_set_number) OVER() AS sum_of_total_sets,
	CAST(1.00* total_set_number/SUM(total_set_number) OVER() AS decimal(5,4))*100 AS percentage_of_total
FROM CTE
) m
WHERE theme_name LIKE '%Train%'


--Most popular theme by year in the 21st century
SELECT 
	YEAR,
	theme_name,
	total_set_num
FROM(
SELECT
	YEAR,
	theme_name,
	COUNT(set_num) AS total_set_num,
	ROW_NUMBER() OVER (PARTITION BY year ORDER BY COUNT(set_num) DESC) rn
FROM [Rebrickable].[dbo].[analytics_main]
WHERE Century ='21st_Century'
GROUP BY YEAR, theme_name
)s
WHERE rn =1
ORDER BY YEAR DESC
go


--Most produced color of LEGO by quantity of parts.
CREATE VIEW dbo.analytics_color AS 
SELECT 
	c.name,
	SUM(CAST(inv.quantity AS numeric)) AS quantiy_of_parts
FROM inventory_parts AS inv
LEFT JOIN colors AS c
ON inv.color_id=c.id
GROUP BY c.name

