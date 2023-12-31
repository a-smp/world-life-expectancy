/*
HEALTH DISPARITIES:
DEVELOPED VS. DEVELOPING NATIONS

ANALYST: ALAN SAMPEDRO
DATE: 2023-12-26
*/



-- Total countries by status
SELECT status,
	   COUNT(DISTINCT country) AS country_tally,
	   ROUND(CAST(COUNT(DISTINCT country) AS NUMERIC) / (SELECT CAST(COUNT(DISTINCT country) AS NUMERIC)
								 					       FROM world_life_expectancy
                                                         ) * 100, 1) AS percent_total
  FROM world_life_expectancy
 GROUP BY status
;


-- Proportion of developed and developing countries by region
SELECT region,
	   COUNT(DISTINCT CASE WHEN status = 'Developed' THEN country END) AS developed_country_tally,
	   ROUND(COUNT(DISTINCT CASE WHEN status = 'Developed' THEN country END) / (SELECT CAST(COUNT(DISTINCT country) AS NUMERIC)
								 					       						  FROM world_life_expectancy
																				 WHERE status = 'Developed'
                                                         						) * 100, 1) AS developed_country_percent_total,
	   COUNT(DISTINCT CASE WHEN status = 'Developing' THEN country END) AS developing_country_tally,
	   ROUND(COUNT(DISTINCT CASE WHEN status = 'Developing' THEN country END) / (SELECT CAST(COUNT(DISTINCT country) AS NUMERIC)
								 					       						   FROM world_life_expectancy
																				  WHERE status = 'Developing'
                                                         						 ) * 100, 1) AS developing_country_percent_total
  FROM world_life_expectancy
 GROUP BY region
 ORDER BY region
;


-- Life expectancy summary statistics by status
SELECT status,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(life_expectancy) AS min_life_expectancy,
	   MAX(life_expectancy) AS max_life_expectancy,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY life_expectancy) AS median_life_expectancy,
	   ROUND(CAST(AVG(life_expectancy) AS NUMERIC), 1) AS avg_life_expectancy,
	   ROUND(CAST(STDDEV(life_expectancy) AS NUMERIC), 1) AS std_life_expectancy
  FROM world_life_expectancy
 GROUP BY status
;


-- Mortality summary statistics by status
SELECT status,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(adult_mortality) AS min_adult_mortality,
	   MAX(adult_mortality) AS max_adult_mortality,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY adult_mortality) AS median_adult_mortality,
	   ROUND(CAST(AVG(adult_mortality) AS NUMERIC), 1) AS avg_adult_mortality,
	   ROUND(CAST(STDDEV(adult_mortality) AS NUMERIC), 1) AS std_adult_mortality
  FROM world_life_expectancy
 GROUP BY status
;


-- GDP summary statistics by status
SELECT status,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(gdp) AS min_gdp,
	   MAX(gdp) AS max_gdp,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gdp) AS median_gdp,
	   ROUND(CAST(AVG(gdp) AS NUMERIC), 1) AS avg_gdp,
	   ROUND(CAST(STDDEV(gdp) AS NUMERIC), 1) AS std_gdp
  FROM world_life_expectancy
 WHERE gdp != 0
 GROUP BY status
;


-- Schooling summary statistics by status
SELECT status,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(schooling) AS min_schooling,
	   MAX(schooling) AS max_schooling,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY schooling) AS NUMERIC), 1) AS median_schooling,
	   ROUND(CAST(AVG(schooling) AS NUMERIC), 1) AS avg_schooling
  FROM world_life_expectancy
 WHERE schooling != 0
 GROUP BY status
;


-- Life expectancy summary statistics in developed countries by region
SELECT region,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(life_expectancy) AS min_life_expectancy,
	   MAX(life_expectancy) AS max_life_expectancy,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY life_expectancy) AS NUMERIC), 1) AS median_life_expectancy,
	   ROUND(CAST(AVG(life_expectancy) AS NUMERIC), 1) AS avg_life_expectancy,
	   ROUND(CAST(STDDEV(life_expectancy) AS NUMERIC), 1) AS std_life_expectancy
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region
 ORDER BY country_tally
;


-- Average life expectancy in developed countries over time
WITH
avg_life_expectancy_cte AS (
SELECT year,
	   ROUND(CAST(AVG(life_expectancy) AS NUMERIC), 1) AS avg_life_expectancy
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY year
)

SELECT year,
	   avg_life_expectancy,
	   COALESCE(avg_life_expectancy - LAG(avg_life_expectancy) OVER (ORDER BY year), 0) AS difference_from_previous_year
  FROM avg_life_expectancy_cte
 ORDER BY year
;


-- Top 5 developed countries with highest life expectancy increase over time
SELECT region, country,
	   MIN(life_expectancy) AS min_life_expectancy,
	   MAX(life_expectancy) AS max_life_expectancy,
	   ROUND(CAST(MAX(life_expectancy) - MIN(life_expectancy) AS NUMERIC),1) AS overall_life_increase
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region, country
 ORDER BY overall_life_increase DESC
 LIMIT 5
;


-- Top 5 developed countries with lowest life expectancy increase over time
SELECT region, country,
	   MIN(life_expectancy) AS min_life_expectancy,
	   MAX(life_expectancy) AS max_life_expectancy,
	   ROUND(CAST(MAX(life_expectancy) - MIN(life_expectancy) AS NUMERIC),1) AS overall_life_increase
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region, country
 ORDER BY overall_life_increase
 LIMIT 5
;


-- Average life expectancy in developed countries per region over time
WITH
life_exp_developed AS (
SELECT region, year, 
	   ROUND(CAST(AVG(life_expectancy) AS NUMERIC), 1) AS avg_life_expectancy
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region, year
 ORDER BY region, year
)
	   
SELECT region, year, avg_life_expectancy,
	   COALESCE(avg_life_expectancy - LAG(avg_life_expectancy) OVER (PARTITION BY region
																		 ORDER BY year), 0) AS difference_from_previous_year
FROM life_exp_developed
ORDER BY region, year
;


-- Mortality summary statistics in developed countries by region
SELECT region,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(adult_mortality) AS min_adult_mortality,
	   MAX(adult_mortality) AS max_adult_mortality,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY adult_mortality) AS median_adult_mortality,
	   ROUND(CAST(AVG(adult_mortality) AS NUMERIC), 1) AS avg_adult_mortality,
	   ROUND(CAST(STDDEV(adult_mortality) AS NUMERIC), 1) AS std_adult_mortality
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region
 ORDER BY country_tally
;


-- Total mortality in developed countries over time
WITH
total_mortality_cte AS (
SELECT year,
	   SUM(adult_mortality) AS total_mortality
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY year
)

SELECT year,
	   total_mortality,
	   COALESCE(total_mortality - LAG(total_mortality) OVER (ORDER BY year), 0) AS difference_from_previous_year
  FROM total_mortality_cte
 ORDER BY year
;


-- Top 5 developed countries with highest mortality increase over time
SELECT region, country,
	   MIN(adult_mortality) AS min_mortality,
	   MAX(adult_mortality) AS max_mortality,
	   ROUND(CAST(MAX(adult_mortality) - MIN(adult_mortality) AS NUMERIC),1) AS overall_mortality_increase
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region, country
 ORDER BY overall_mortality_increase DESC
 LIMIT 5
;


-- Top 5 developed countries with lowest mortality increase over time
SELECT region, country,
	   MIN(adult_mortality) AS min_mortality,
	   MAX(adult_mortality) AS max_mortality,
	   ROUND(CAST(MAX(adult_mortality) - MIN(adult_mortality) AS NUMERIC),1) AS overall_mortality_increase
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region, country
 ORDER BY overall_mortality_increase
 LIMIT 5
;


-- Rolling total of mortality in developed countries per region over time
WITH
life_exp_developed AS (
SELECT region, year, 
	   SUM(adult_mortality) AS adult_mortality
  FROM world_life_expectancy
 WHERE status = 'Developed'
 GROUP BY region, year
 ORDER BY region, year
)
	   
SELECT region, year, adult_mortality AS total_mortality,
	   SUM(adult_mortality) OVER(PARTITION BY region
								 ORDER BY year) AS mortality_rolling_total
FROM life_exp_developed
;


-- Life expectancy summary statistics in developing countries by region
SELECT region,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(life_expectancy) AS min_life_expectancy,
	   MAX(life_expectancy) AS max_life_expectancy,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY life_expectancy) AS NUMERIC), 1) AS median_life_expectancy,
	   ROUND(CAST(AVG(life_expectancy) AS NUMERIC), 1) AS avg_life_expectancy,
	   ROUND(CAST(STDDEV(life_expectancy) AS NUMERIC), 1) AS std_life_expectancy
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region
 ORDER BY country_tally
;


-- Average life expectancy in developing countries over time
WITH
avg_life_expectancy_cte AS (
SELECT year,
	   ROUND(CAST(AVG(life_expectancy) AS NUMERIC), 1) AS avg_life_expectancy
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY year
)

SELECT year,
	   avg_life_expectancy,
	   COALESCE(avg_life_expectancy - LAG(avg_life_expectancy) OVER (ORDER BY year), 0) AS difference_from_previous_year
  FROM avg_life_expectancy_cte
 ORDER BY year
;


-- Top 5 developing countries with highest life expectancy increase over time
SELECT region, country,
	   MIN(life_expectancy) AS min_life_expectancy,
	   MAX(life_expectancy) AS max_life_expectancy,
	   ROUND(CAST(MAX(life_expectancy) - MIN(life_expectancy) AS NUMERIC),1) AS life_increase_15_years
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region, country
 ORDER BY life_increase_15_years DESC
 LIMIT 5
;


-- Top 5 developing countries with lowest life expectancy increase over time
SELECT region, country,
	   MIN(life_expectancy) AS min_life_expectancy,
	   MAX(life_expectancy) AS max_life_expectancy,
	   ROUND(CAST(MAX(life_expectancy) - MIN(life_expectancy) AS NUMERIC),1) AS life_increase_15_years
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region, country
 ORDER BY life_increase_15_years
 LIMIT 5
;


-- Average life expectancy in developing countries per region over time
WITH
life_exp_developed AS (
SELECT region, year, 
	   ROUND(CAST(AVG(life_expectancy) AS NUMERIC), 1) AS avg_life_expectancy
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region, year
 ORDER BY region, year
)
	   
SELECT region, year, avg_life_expectancy,
	   COALESCE(avg_life_expectancy - LAG(avg_life_expectancy) OVER (PARTITION BY region
																		 ORDER BY year), 0) AS difference_from_previous_year
FROM life_exp_developed
ORDER BY region, year
;


-- Mortality summary statistics in developing countries by region
SELECT region,
	   COUNT(DISTINCT country) AS country_tally,
	   MIN(adult_mortality) AS min_adult_mortality,
	   MAX(adult_mortality) AS max_adult_mortality,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY adult_mortality) AS median_adult_mortality,
	   ROUND(CAST(AVG(adult_mortality) AS NUMERIC), 1) AS avg_adult_mortality,
	   ROUND(CAST(STDDEV(adult_mortality) AS NUMERIC), 1) AS std_adult_mortality
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region
 ORDER BY country_tally
;


-- Total mortality in developing countries over time
WITH
total_mortality_cte AS (
SELECT year,
	   SUM(adult_mortality) AS total_mortality
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY year
)

SELECT year,
	   total_mortality,
	   COALESCE(total_mortality - LAG(total_mortality) OVER (ORDER BY year), 0) AS difference_from_previous_year
  FROM total_mortality_cte
 ORDER BY year
;


-- Top 5 developed countries with highest mortality increase over time
SELECT region, country,
	   MIN(adult_mortality) AS min_mortality,
	   MAX(adult_mortality) AS max_mortality,
	   ROUND(CAST(MAX(adult_mortality) - MIN(adult_mortality) AS NUMERIC),1) AS overall_mortality_increase
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region, country
 ORDER BY overall_mortality_increase DESC
 LIMIT 5
;


-- Top 5 developed countries with lowest mortality increase over time
SELECT region, country,
	   MIN(adult_mortality) AS min_mortality,
	   MAX(adult_mortality) AS max_mortality,
	   ROUND(CAST(MAX(adult_mortality) - MIN(adult_mortality) AS NUMERIC),1) AS overall_mortality_increase
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region, country
 ORDER BY overall_mortality_increase
 LIMIT 5
;


-- Rolling total of mortality in developing countries per region over time
WITH
life_exp_developed AS (
SELECT region, year, 
	   SUM(adult_mortality) AS adult_mortality
  FROM world_life_expectancy
 WHERE status = 'Developing'
 GROUP BY region, year
 ORDER BY region, year
)
	   
SELECT region, year, adult_mortality AS total_mortality,
	   SUM(adult_mortality) OVER(PARTITION BY region
								     ORDER BY year) AS mortality_rolling_total
FROM life_exp_developed
;


-- Overal median GDP and schooling per life expectancy quartile by region
WITH
life_exp_bins AS ( 
SELECT region, country, ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY life_expectancy) AS NUMERIC), 1) AS median_life_exp,
	   CASE
	   WHEN PERCENT_RANK() OVER(PARTITION BY region
									ORDER BY ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY life_expectancy) AS NUMERIC), 1) DESC
							    ) < 0.25 THEN '1st'
	   WHEN PERCENT_RANK() OVER(PARTITION BY region
									ORDER BY ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY life_expectancy) AS NUMERIC), 1) DESC
							    ) < 0.50 THEN '2nd'
	   WHEN PERCENT_RANK() OVER(PARTITION BY region
									ORDER BY ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY life_expectancy) AS NUMERIC), 1) DESC
							    ) < 0.75 THEN '3rd'
	   ELSE '4th'
	   END AS life_exp_quartiles
  FROM world_life_expectancy
 WHERE gdp != 0
    OR schooling != 0
 GROUP BY region, country
 ORDER BY region
),

median_gdp_schooling AS (
SELECT leb.region, leb.country, leb.median_life_exp, leb.life_exp_quartiles,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY wle.gdp) AS NUMERIC), 1) AS country_median_gdp,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY wle.schooling) AS NUMERIC), 1) AS country_median_schooling
  FROM life_exp_bins leb
  	   JOIN world_life_expectancy wle
		 ON leb.region = wle.region
		AND leb.country = wle.country
 GROUP BY leb.region, leb.country, leb.median_life_exp, leb.life_exp_quartiles
 ORDER BY leb.region, leb.country, leb.median_life_exp, leb.life_exp_quartiles
)

SELECT region, life_exp_quartiles,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY country_median_gdp) AS NUMERIC), 1) AS region_median_gdp, 
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY country_median_schooling) AS NUMERIC), 1) AS region_median_schooling
  FROM median_gdp_schooling
 GROUP BY region, life_exp_quartiles
 ORDER BY region, life_exp_quartiles
;


-- Overal median GDP and schooling per mortality quartile by region
WITH
mortality_bins AS ( 
SELECT region, country, ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY adult_mortality) AS NUMERIC), 1) AS median_mortality,
	   CASE
	   WHEN PERCENT_RANK() OVER(PARTITION BY region
									ORDER BY ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY adult_mortality) AS NUMERIC), 1) DESC
							    ) < 0.25 THEN '1st'
	   WHEN PERCENT_RANK() OVER(PARTITION BY region
									ORDER BY ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY adult_mortality) AS NUMERIC), 1) DESC
							    ) < 0.50 THEN '2nd'
	   WHEN PERCENT_RANK() OVER(PARTITION BY region
									ORDER BY ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY adult_mortality) AS NUMERIC), 1) DESC
							    ) < 0.75 THEN '3rd'
	   ELSE '4th'
	   END AS mortality_quartiles
  FROM world_life_expectancy
 WHERE gdp != 0
    OR schooling != 0
 GROUP BY region, country
 ORDER BY region
),

median_gdp_schooling AS (
SELECT mb.region, mb.country, mb.median_mortality, mb.mortality_quartiles,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY wle.gdp) AS NUMERIC), 1) AS country_median_gdp,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY wle.schooling) AS NUMERIC), 1) AS country_median_schooling
  FROM mortality_bins mb
  	   JOIN world_life_expectancy wle
		 ON mb.region = wle.region
		AND mb.country = wle.country
 GROUP BY mb.region, mb.country, mb.median_mortality, mb.mortality_quartiles
 ORDER BY mb.region, mb.country, mb.median_mortality, mb.mortality_quartiles
)

SELECT region, mortality_quartiles,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY country_median_gdp) AS NUMERIC), 1) AS region_median_gdp, 
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY country_median_schooling) AS NUMERIC), 1) AS region_median_schooling
  FROM median_gdp_schooling
 GROUP BY region, mortality_quartiles
 ORDER BY region, mortality_quartiles
;

-- Regional trends over time
WITH
regional_trends AS (
SELECT region, year, status,
	   SUM(adult_mortality) AS total_mortality,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY life_expectancy) AS NUMERIC), 1) AS median_life_exp,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gdp) AS NUMERIC), 1) AS median_gdp,
	   ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY schooling) AS NUMERIC), 1) AS median_schooling
  FROM world_life_expectancy
 WHERE gdp != 0
    OR schooling != 0
 GROUP BY region, year, status
 ORDER BY region, year, status
)
	   
SELECT region, year, status, median_life_exp,
	   COALESCE(median_life_exp - LAG(median_life_exp) OVER (PARTITION BY region, status
															 ORDER BY year), 0) AS life_exp_diff,
	   total_mortality,
	   SUM(total_mortality) OVER(PARTITION BY region
								 ORDER BY year) AS mortality_rolling_total,
	   median_gdp, median_schooling
 FROM regional_trends
GROUP BY region, year, status, median_life_exp, total_mortality, median_gdp, median_schooling
ORDER BY region, status, year
;


-- Normalize relevant variables and apply logarithmic transformation to help reduce the influence of extreme values
SELECT year, region,
	   (LOG(life_expectancy)-AVG(LOG(life_expectancy)) OVER()) / STDDEV(LOG(life_expectancy)) OVER() AS life_expectancy_log_zscore,
	   (LOG(adult_mortality)-AVG(LOG(adult_mortality)) OVER()) / STDDEV(LOG(adult_mortality)) OVER() AS mortality_log_zscore,
	   (LOG(gdp)-AVG(LOG(gdp)) OVER()) / STDDEV(LOG(gdp)) OVER() AS gdp_log_zscore,
	   (LOG(schooling)-AVG(LOG(schooling)) OVER()) / STDDEV(LOG(schooling)) OVER() AS schooling_log_zscore
  FROM world_life_expectancy
 WHERE gdp != 0
   AND schooling != 0
;