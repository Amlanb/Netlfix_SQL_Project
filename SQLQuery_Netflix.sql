-- Netflix 

SELECT
	COUNT(*) as total_content
FROM Netflix;

SELECT
	Distinct type
FROM Netflix;

SELECT * FROM Netflix

--15 Business Problems

-- 1. 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) as total_content
FROM Netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating
FROM
(
	SELECT 
		type,
		rating,
		COUNT(*) AS count,
		RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM dbo.Netflix
	GROUP BY type, rating
) as t1
WHERE
	ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM Netflix;

-- filter 2020
-- movies

SELECT * FROM Netflix
WHERE 
	type = 'Movie'
	AND 
	release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

-- Ensure to count total content per country and split countries into new rows
;WITH CountryContent AS (
    SELECT
        country,
        COUNT(show_id) AS total_content
    FROM Netflix
    GROUP BY country
)

SELECT TOP 5
    new_country.value AS new_country,
    cc.total_content
FROM CountryContent cc
CROSS APPLY STRING_SPLIT(cc.country, ',') AS new_country
ORDER BY cc.total_content DESC;

-- 5. Identify the longest movie

SELECT * FROM Netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM Netflix)

-- 6. Find content added in the last 5 years

SELECT *
FROM Netflix
WHERE
    CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
    *
FROM Netflix
WHERE 
    type = 'TV Show'
    AND 
    CHARINDEX(' ', duration) > 0 
    AND 
    TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

-- 9. Count the number of content items in each genre

SELECT
    TRIM(value) AS genre,
    COUNT(show_id) AS total_content
FROM Netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value);

-- 10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!

SELECT 
    YEAR(CONVERT(DATE, date_added, 101)) AS year,
    COUNT(*) AS yearly_content,
    FORMAT(
        ROUND(
            COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM Netflix WHERE country = 'India'), 0), 2
        ), 
        'N2'
    ) AS average_content_per_year
FROM Netflix
WHERE country = 'India'
GROUP BY YEAR(CONVERT(DATE, date_added, 101));

-- 11. List all movies that are documentaries

SELECT * FROM Netflix
WHERE listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director

SELECT * FROM Netflix
WHERE director = ' ';

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * 
FROM Netflix
WHERE LOWER(cast) LIKE LOWER('%Salman Khan%')
AND release_year > YEAR(GETDATE()) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    TRIM(value) AS actors,
    COUNT(*) AS total_content
FROM Netflix
CROSS APPLY STRING_SPLIT(cast, ',') AS SplitActors
WHERE cast IS NOT NULL AND TRIM(value) <> ''
GROUP BY TRIM(value)
HAVING COUNT(*) > 0
ORDER BY total_content DESC;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

WITH new_table AS (
    SELECT
        *,
        CASE
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad_Content'
            ELSE 'Good_Content'
        END AS category
    FROM Netflix
)
SELECT
    category,
    COUNT(*) AS total_content
FROM new_table
GROUP BY category;
