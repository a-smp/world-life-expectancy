/*

WORLD LIFE EXPECTANCY PROJECT
DATA PREPROCESSING

ANALYST: ALAN SAMPEDRO
DATE: 2023-12-19

*/


--explore table
SELECT *
  FROM world_life_expectancy
;


-- evaluate for duplicated records
SELECT country, year, 
	   COUNT(CONCAT(country, year)) AS unique_rows
  FROM world_life_expectancy
 GROUP BY country, year
HAVING COUNT(CONCAT(country, year)) > 1
;


-- identify row_id of duplicated records
SELECT row_id 
  FROM (SELECT row_id,
	   		   CONCAT(country, year),
	   		   ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year)
	  					      	     ORDER BY CONCAT(country, year)
	  						    ) AS row_num
  	  	  FROM world_life_expectancy
	   ) AS row_table
WHERE row_num > 1
;


-- remove duplicated records
DELETE FROM world_life_expectancy
 WHERE row_id IN (SELECT row_id 
  				    FROM (SELECT row_id,
	   		   	 				 CONCAT(country, year),
	   		  	 	 			 ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year)
	  			 		      	     			 	  ORDER BY CONCAT(country, year)
	  			 			    				  ) AS row_num
  	  	  		 		    FROM world_life_expectancy
	   			 		 ) AS row_table
				   WHERE row_num > 1
 				 )
;

-- assess for nulls in status field
SELECT *
  FROM world_life_expectancy
 WHERE status IS NULL
;


-- return unique values in status field
SELECT DISTINCT(status)
  FROM world_life_expectancy
 WHERE status IS NOT NULL
;


-- impute nulls in status field where country is 'Developing'
UPDATE world_life_expectancy
   SET status = 'Developing'
 WHERE country IN (SELECT DISTINCT(country)
				     FROM world_life_expectancy
				    WHERE status = 'Developing') -- list of 'developing' countries
;
					

-- impute nulls in status field where country is 'developed'
UPDATE world_life_expectancy
   SET status = 'Developed'
 WHERE country IN (SELECT DISTINCT(country)
				     FROM world_life_expectancy
				    WHERE status = 'Developed') -- list of 'developed' countries
;


-- assess for nulls in life_expectancy field
SELECT *
  FROM world_life_expectancy
 WHERE life_expectancy IS NULL
;


--calculte the avg of neighboring rows around null values in life_expectancy field
SELECT t1.country, t1.year, t1.life_expectancy,
	   t2.country, t2.year, t2.life_expectancy,
	   t3.country, t3.year, t3.life_expectancy,
	   ROUND(CAST((t2.life_expectancy + t3.life_expectancy) / 2 AS numeric), 1) AS avg_life_expectancy
  FROM world_life_expectancy t1
  	   JOIN world_life_expectancy t2
	   	 ON t1.country = t2.country
		 	AND t1.year = t2.year - 1
	   JOIN world_life_expectancy t3
	   	 ON t1.country = t3.country
		 	AND t1.year = t3.year + 1
 WHERE t1.life_expectancy IS NULL
 ;
 

-- impute nulls in life_expectancy field with calculated avg of neighboring rows
UPDATE world_life_expectancy tt
   SET life_expectancy = it.avg_life_expectancy
  FROM (SELECT t1.country,
	   		   t1.year,
	   	   	   ROUND(CAST((t2.life_expectancy + t3.life_expectancy) / 2 AS numeric), 1) AS avg_life_expectancy
  	      FROM world_life_expectancy t1
  	   		   JOIN world_life_expectancy t2
	   			 ON t1.country = t2.country
	    			AND t1.year = t2.year - 1
	   		   JOIN world_life_expectancy t3
	   			 ON t1.country = t3.country
	    			AND t1.year = t3.year + 1
 	   	 WHERE t1.life_expectancy IS NULL
  	   ) AS it
 WHERE tt.country = it.country
   AND tt.year = it.year
;


-- Remove 10 unique records of small countries with missing values
DELETE FROM world_life_expectancy
 WHERE row_id IN (SELECT row_id
					FROM world_life_expectancy
				   WHERE life_expectancy = 0
					 AND year = 2020)
;


-- Add region field to the dataset
ALTER TABLE world_life_expectancy
  ADD COLUMN region TEXT;


-- Populate region field
UPDATE world_life_expectancy
   SET region =
   	   CASE
	   WHEN country IN ('Antigua and Barbuda', 'Bahamas', 'Barbados', 'Belize', 'Canada', 'Costa Rica', 'Cuba',
						'Dominica', 'Dominican Republic', 'El Salvador', 'Grenada', 'Guatemala', 'Haiti', 'Honduras',
						'Jamaica', 'Mexico', 'Nicaragua', 'Panama', 'Saint Kitts and Nevis', 'Saint Lucia',
						'Saint Vincent and the Grenadines', 'Trinidad and Tobago', 'United States of America',
						'Argentina', 'Bolivia (Plurinational State of)', 'Brazil', 'Chile', 'Colombia', 'Ecuador',
						'Guyana', 'Paraguay', 'Peru', 'Suriname', 'Uruguay', 'Venezuela (Bolivarian Republic of)'
					    ) THEN 'Americas'
	   WHEN country IN ('Algeria', 'Angola', 'Benin', 'Botswana', 'Burkina Faso', 'Burundi', 'Cabo Verde','Cameroon',
						'Central African Republic', 'Chad', 'Comoros', 'Congo', 'Côte d''Ivoire',
						'Democratic Republic of the Congo', 'Djibouti', 'Egypt', 'Equatorial Guinea', 'Eritrea',
						'Eswatini', 'Ethiopia', 'Gabon', 'Gambia', 'Ghana', 'Guinea', 'Guinea-Bissau', 'Kenya',
						'Lesotho', 'Liberia', 'Libya', 'Madagascar', 'Malawi', 'Mali', 'Mauritania', 'Mauritius',
						'Morocco', 'Mozambique', 'Namibia', 'Niger', 'Nigeria', 'Rwanda', 'Sao Tome and Principe',
						'Senegal', 'Seychelles', 'Sierra Leone', 'Somalia', 'South Africa', 'South Sudan', 'Sudan',
						'Swaziland','Tanzania', 'Togo', 'Tunisia', 'Uganda', 'United Republic of Tanzania', 'Zambia', 'Zimbabwe'
	   					) THEN 'Africa'
	   WHEN country IN ('Afghanistan', 'Armenia', 'Azerbaijan', 'Bahrain', 'Bangladesh', 'Bhutan', 'Brunei Darussalam',
						'Cambodia', 'China', 'Democratic People''s Republic of Korea', 'Georgia', 'India', 'Indonesia',
						'Iran (Islamic Republic of)', 'Iraq', 'Israel', 'Japan', 'Jordan', 'Kazakhstan', 'Kuwait',
						'Kyrgyzstan', 'Lao People''s Democratic Republic', 'Lebanon', 'Malaysia', 'Maldives', 'Mongolia',
						'Myanmar', 'Nepal', 'North Korea', 'Oman', 'Pakistan', 'Philippines', 'Qatar', 'Republic of Korea',
						'Saudi Arabia', 'Singapore', 'South Korea', 'Sri Lanka', 'Syrian Arab Republic', 'Tajikistan',
						'Thailand', 'The former Yugoslav republic of Macedonia', 'Timor-Leste', 'Turkey', 'Turkmenistan',
						'United Arab Emirates', 'Uzbekistan', 'Viet Nam', 'Yemen'
	   					) THEN 'Asia'
	   WHEN country IN ('Albania', 'Andorra', 'Austria', 'Belarus', 'Belgium', 'Bosnia and Herzegovina', 'Bulgaria',
						'Croatia', 'Cyprus', 'Czechia', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece',
						'Hungary', 'Iceland', 'Ireland', 'Italy', 'Kosovo', 'Latvia', 'Liechtenstein', 'Lithuania',
						'Luxembourg', 'Malta', 'Mauritius', 'Moldova', 'Monaco', 'Montenegro', 'Netherlands', 'Norway',
						'Poland', 'Portugal', 'Qatar', 'Republic of Moldova', 'Romania', 'Russian Federation',
						'San Marino', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine',
						'United Kingdom of Great Britain and Northern Ireland', 'Vatican City'
	   					) THEN 'Europe'
	   WHEN country IN ('Australia', 'Fiji', 'Kiribati', 'Marshall Islands', 'Micronesia (Federated States of)', 'Nauru',
						'New Zealand', 'Palau', 'Papua New Guinea', 'Samoa', 'Solomon Islands', 'Tonga', 'Tuvalu', 'Vanuatu'
	   					) THEN 'Oceania'
		END;