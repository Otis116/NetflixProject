SELECT 
     *
FROM 
     netflix_titles

--TOTAL MOVIES VS TV SHOWS

SELECT 
     type, 
	 COUNT(type) AS Total
FROM 
     netflix_titles
GROUP BY 
     type


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


--GENRE POPULARITY

SELECT 
      show_id, 
	  type, title, 
	  country, 
	  release_year, 
	  rating, 
	  duration, 
	  listed_in
FROM 
      netflix_titles
WHERE 
      type NOT LIKE'%Movie%' 
--Option to use "Tv Show" in place of "Movies" to see the overview


SELECT
    show_id,
	type,
    listed_in,
    value AS Category,
    COUNT(*) OVER(PARTITION BY show_id, value) AS CategoryCount
FROM
    netflix_titles
CROSS APPLY
    STRING_SPLIT(listed_in, ',');


--BREAKDOWN OF TOTALS OF MOVIES/TV SHOWS BY CATEGORY

WITH CategoryCounts AS (
SELECT
    show_id,
	type,
    listed_in,
    value AS Category,
    COUNT(*) OVER(PARTITION BY show_id, value) AS CategoryCount
FROM
    netflix_titles
CROSS APPLY
    STRING_SPLIT(listed_in, ',')
	)

SELECT 
     type, 
	 Category, 
	 Sum (CategoryCount) As Total
FROM 
     CategoryCounts
GROUP BY  
     type, 
	 Category
ORDER BY 
     3 DESC

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

--COUNTRY BREAKDOWN 

SELECT
    show_id,
	type,
    country,
    value AS Country_Origin,
    COUNT(*) OVER(PARTITION BY show_id, value) AS Total_Titles
FROM
    netflix_titles
CROSS APPLY
    STRING_SPLIT(country, ',');


WITH Country_Totals AS (

SELECT
    show_id,
	type,
    country,
    value AS Country_Origin,
    COUNT(*) OVER(PARTITION BY show_id, value) AS Total_Titles
FROM
    netflix_titles
CROSS APPLY
    STRING_SPLIT(country, ',')
	)

SELECT 
     Country_Origin, 
	 SUM(Total_Titles) As Total
FROM 
     Country_Totals
GROUP BY 
     Country_Origin, 
	 Total_Titles
ORDER BY 
     2 Desc


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

--BY RELEASE YEAR

SELECT 
     release_year, 
	 COUNT(release_year) AS Total
FROM 
     netflix_titles
GROUP BY  
     release_year
ORDER BY 
     2 DESC


SELECT 
      release_year, 
	  date_added, 
	  COUNT(release_year) AS Total
FROM 
      netflix_titles
WHERE 
      date_added LIKE '%2021'
GROUP BY 
     release_year, 
	 date_added
ORDER BY 
     2 DESC

--The Year '%2021' could be replaced by a different one to further explore. 

--How Many Movies or Tv Shows were released in a particular year(s)?

SELECT 
    release_year,
    SUM(CASE WHEN type LIKE '%TV SHOW%' THEN 1 ELSE 0 END) AS TV_Shows_Count,
    SUM(CASE WHEN type LIKE '%MOVIE%' THEN 1 ELSE 0 END) AS Movies_Count
FROM 
    netflix_titles
WHERE  
    release_year IN (2015,2016,2017, 2018,2019,2020,2021, 2022, 2023, 2024)
GROUP BY 
    release_year
ORDER BY 
    1 

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


--DURATION OF THE MOVIES AND TV SHOWS

--The Longest Running Tv Shows on Netflix

SELECT 
      title, 
	  duration
FROM 
      netflix_titles
WHERE type LIKE '%Tv Show'
ORDER BY 2 DESC

--Season duration by totals
SELECT 
      duration, 
	  COUNT(duration) AS Duration_Count
FROM 
      netflix_titles
WHERE 
      type LIKE '%Tv Show'
GROUP BY 
      duration
ORDER BY 
      1 DESC


--The Longest Running Tv Shows in Netflix in Each Year of release Year

SELECT 
        release_year,
        title,
        duration,
        ROW_NUMBER() OVER (PARTITION BY release_year ORDER BY duration DESC) AS rn
    FROM 
        netflix_titles
	WHERE 
	    type LIKE '%Tv Show'

WITH Longest_Tvshows AS (

SELECT 
        release_year,
        title,
        duration,
        ROW_NUMBER() OVER (PARTITION BY release_year ORDER BY duration DESC) AS Pos
    FROM 
        netflix_titles
	WHERE 
	    type LIKE '%Tv Show'
	)

SELECT 
      release_year, 
	  title, 
	  duration
FROM 
      Longest_Tvshows 
WHERE  
      Pos = 1
ORDER BY 
      1 DESC


--The Longest Movie Duration in Netflix in Each Year of release Year 

WITH Longest_Movie AS (

SELECT 
        release_year,
        title,
        duration,
        ROW_NUMBER() OVER (PARTITION BY release_year ORDER BY duration DESC) AS Pos
    FROM 
        netflix_titles
	WHERE 
	    type LIKE '%Movie'
	)

SELECT 
     release_year,  
	 title, 
	 duration
FROM 
     Longest_Movie 
WHERE 
     Pos = 1
ORDER BY 
     1 DESC


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

--HIGHLIGHT OF MAJOR THEMES MOVIES/TV SHOWS

SELECT title, 
       type, 
	   release_year, 
	   listed_in,
	   description
FROM 
        netflix_titles
WHERE
       description LIKE '%death%'

ORDER BY 
       3 DESC

--The above query intends to find the underkying themes in the various tv shows and movies in Netflix. The word "Kill" can be replaced with sex, Love, death etc

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

--PERCENTAGE OF RATINGS OF MOVIES AND TV SHOWS


SELECT 
     rating, 
	 type,
	 ROUND(COUNT(rating) * 100.0 / (SELECT COUNT(*) FROM netflix_titles),2) AS percentage
FROM 
     netflix_titles
WHERE 
     type = 'Movie'
GROUP BY  
     rating, 
	 type
ORDER BY
     3 DESC



