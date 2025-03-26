-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems

-- 1. Count the number of Movies vs TV Shows
SELECT DISTINCT COUNT(show_id) 
FROM netflix;

SELECT 
	type,
	count(*)
FROM netflix
GROUP BY 1;


-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- Alternative 
SELECT DISTINCT ON (type) --  first row for each unique type.
    type,
    rating,
    COUNT(*) AS rating_count
FROM netflix
GROUP BY type, rating
ORDER BY type, rating_count DESC;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix 
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- Alternative --> still need unnest for country with more countries in cell
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
	COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;

SELECT country from netflix;


-- 5. Identify the longest movie
SELECT 
	type,
	title,
	duration
FROM netflix 
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ',1)::INT DESC
LIMIT 1;


-- 6. Find content added in the last 5 years
SELECT 
	type,
	title,
	date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Taylor Sheridan'!
SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS director
FROM netflix
WHERE director = 'Taylor Sheridan';

-- Alternative
SELECT *
FROM ( 
	SELECT 
		*,
		UNNEST(STRING_TO_ARRAY(director,',')) AS director_name
	FROM netflix
) AS t
WHERE director_name= 'Taylor Sheridan';


-- 8. List all TV shows with more than 5 seasons
SELECT
	type,
	title,
	duration
FROM netflix
WHERE type = 'TV Show' 
	AND SPLIT_PART(duration, ' ', 1)::INT > 5;


-- 9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(*) AS total_count
FROM netflix
GROUP BY genre
ORDER BY total_count DESC;


-- 10. Find each year and the average numbers of content release by Germany on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /(SELECT COUNT(show_id) FROM netflix WHERE country = 'Germany')::numeric * 100, 2) AS avg_release
FROM netflix
WHERE country = 'Germany'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries';


-- 12. Find all content without a director
SELECT * 
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Adam Sandler' appeared in last 10 years!
SELECT *
FROM netflix
WHERE casts LIKE '%Adam Sandler%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highestd number of movies produced in United States.
SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actor,
	COUNT(*)
FROM netflix
WHERE country = 'United States'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
--Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;