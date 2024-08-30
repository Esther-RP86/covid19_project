-- Creating and using database covid_19
CREATE DATABASE covid_19;

USE covid_19;

-- Setting empty cell/string as null
UPDATE deaths
SET new_deaths = null
WHERE new_deaths = '';

UPDATE deaths
SET total_deaths_per_million = null
WHERE total_deaths_per_million = '';

UPDATE deaths
SET new_deaths_per_million = null
WHERE new_deaths_per_million = '';

UPDATE deaths
SET date = str_to_date(date, '%m/%d/%y');

UPDATE deaths
SET continent = null
WHERE continent = '';

-- Data Validation and correction: 
	-- Setting correct data type to columns
ALTER TABLE deaths
MODIFY COLUMN date DATE,
MODIFY COLUMN total_deaths INT,
MODIFY COLUMN new_deaths INT,
MODIFY COLUMN total_deaths_per_million DOUBLE,
MODIFY COLUMN new_deaths_per_million DOUBLE;

	-- Checking for negative values in new_cases
SELECT *
FROM deaths
WHERE new_cases < 0;

	-- Checking for negative values in new_deaths
SELECT *
FROM deaths
WHERE new_deaths < 0;

	-- Checking for negative values in new_cases_per_million
SELECT *
FROM deaths
WHERE new_cases_per_million < 0;

	-- Checking for negative values in new_cases_per_million
SELECT *
FROM deaths
WHERE new_deaths_per_million < 0;

		-- Findings: Negative numbers found in all new_cases, new_deaths, new_cases_per_million, & new_deaths_per_million, research found that the negative values are due to data correction as a result of previous over-counting of cases and deaths.


-- Reviewing deaths table
SELECT *
FROM deaths;

-- Extracting the highest death rate for each month of the two years in China using CTE (evaluating cases in china) and seeing the trends in deathrate
WITH percentage_death_rate AS
	(SELECT location, 
			date, 
			EXTRACT(Year FROM date) AS year, 
            MONTHNAME(date) AS month,
            new_cases, 
            total_cases, 
			CASE WHEN new_deaths IS NULL THEN 0 ELSE new_deaths END AS new_deaths,
			total_deaths, 
			(total_deaths/total_cases)*100 AS death_rate
	FROM deaths
	WHERE LOWER(location) LIKE '%China%' AND continent IS NOT NULL
	ORDER BY year)

SELECT month, year, MAX(death_rate) AS max_death_rate
FROM percentage_death_rate
GROUP BY month, year;

-- Cumulative cases & infection rate in percentage for each continent and location by July 2021 
SELECT continent,location, population, MAX(total_cases) AS cases, ROUND(MAX((total_cases)/population*100),2) AS infection_rate
FROM deaths
WHERE continent IS NOT NULL 
GROUP BY location, population, continent
ORDER BY continent, infection_rate DESC, cases DESC;

-- Cumulative death & deaths per population in July 2021
SELECT location, continent, population, MAX(total_deaths) AS number_of_deaths, MAX((total_deaths/population)*100) AS deaths_per_population
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location, population, continent
ORDER BY deaths_per_population DESC;

-- Locating the place with top 10 highest death percentage 
WITH sum_data_per_location AS
	(SELECT location, population, SUM(new_cases) AS overall_cases, SUM(total_deaths) AS overall_deaths
	 FROM deaths
     WHERE continent IS NOT NULL
     GROUP BY location, population)
     
SELECT location, overall_cases, overall_deaths, (overall_deaths/overall_cases) AS death_percentage
FROM sum_data_per_location
ORDER BY death_percentage DESC;

-- Global case and deaths
SELECT SUM(new_cases) AS global_cases, SUM(total_deaths) AS global_deaths
FROM deaths
WHERE continent IS NOT NULL;



     




















