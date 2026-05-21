CREATE DATABASE hr;
USE hr;

RENAME TABLE `human resources` TO Human_Resources;

ALTER TABLE Human_Resources
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

ALTER TABLE Human_Resources
ADD COLUMN Full_Name VARCHAR(30)
AFTER last_name;

ALTER TABLE Human_Resources
DROP COLUMN  Full_Name;

UPDATE Human_Resources
SET Full_Name = CONCAT(first_name, ' ', last_name);

DESCRIBE Human_Resources;
SELECT * FROM Human_Resources;
                                      /*DATE CORRECTION*/
                                      
SET SQL_SAFE_UPDATES = 0;

UPDATE Human_Resources
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' 
        THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
        
    WHEN birthdate LIKE '%-%' 
        THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%Y-%m-%d'), '%Y-%m-%d')
        
    ELSE NULL
END;

ALTER TABLE Human_Resources
MODIFY birthdate DATE;

UPDATE Human_Resources
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' 
        THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
        
    WHEN hire_dte LIKE '%-%'   -- ✅ corrected (was birthdate before)
        THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
        
    ELSE NULL
END;

ALTER TABLE Human_Resources
MODIFY COLUMN hire_date DATE;

SET sql_safe_updates =0;

UPDATE Human_Resources 
SET termdate = NULL
WHERE termdate = '';

UPDATE Human_Resources
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL ;

ALTER TABLE Human_Resources
MODIFY COLUMN termdate DATE;


                                              /*AGE CALCULATION*/
                
ALTER TABLE Human_Resources
ADD COLUMN Age INT ;

UPDATE Human_Resources
SET Age = TIMESTAMPDIFF( year,birthdate , curdate());

SELECT MIN(Age) MINIMUM_AGE , MAX(Age) MAXIMUM_AGE FROM Human_Resources ;
SELECT COUNT(Age) FROM Human_Resources WHERE Age < 18;

											/*AGE BREAKDOWN OF EMPLOYEES IN THE COMPANY*/

SELECT 
        gender , 
        count(*) as gender_count
		FROM Human_Resources
		WHERE Age >= 18
		GROUP BY gender;

										/*RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY*/
                                        

SELECT 
		race , 
		count(*) as race_count
		FROM Human_Resources
		WHERE Age >= 18
		GROUP BY race
		ORDER BY race_count DESC;

										/*AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY*/
                                        
SELECT 
		MIN(Age) AS Youngest , 
		MAX(Age) AS Oldest 
		FROM Human_Resources 
		WHERE Age >= 18 ;

SELECT
     CASE
		WHEN Age>=18 AND Age<=24 THEN '18-24'
		WHEN Age>=25 AND Age<=34 THEN '25-34'
		WHEN Age>=35 AND Age<=44 THEN '35-44'
		WHEN Age>=45 AND Age<=54 THEN '45-54'
		WHEN Age>=55 AND Age<=65 THEN '55-65'
		ELSE '65+'
		END AS  Age_Group,gender,
		COUNT(*) AS Age_Count
		FROM Human_Resources
		WHERE  Age>=18
		GROUP BY Age_Group , gender
		ORDER BY Age_Group,gender;
             
             
									/* EMPLOYEES WORKING IN HEADQUARTERS VERSUS REMOTE LOCATIONS*/
             
SELECT 
		location, 
		COUNT(*) AS Location_Distribution
		FROM Human_Resources
		WHERE  Age>=18
		GROUP BY location ;

									/* AVERAGE LENGH OF EMPLOYEES WORKING IN THE COMPANY BEFORE TERMINATION*/
                                    
SELECT 
		ROUND(AVG(DATEDIFF(termdate,hire_date))/365,0) AS Avg_Length_Employment
		FROM Human_Resources
		WHERE  Age >=18 AND termdate<= curdate() AND termdate IS NOT NULL;
        
									/* DISTRIBUTION OF JOB TITLE ACROSS THE COMPANY */
                                    
        SELECT  
			jobtitle ,
			COUNT(*)  AS Total_Titles
        	FROM Human_Resources
            WHERE  Age >=18
            GROUP BY jobtitle
            ORDER BY jobtitle DESC;
									/* TURNOVER RATE OF EMPLOYEES IN THE COMPANY */
                                    
SELECT
		department,
		Total_Count , 
        Termination_Count,
		ROUND((Total_Count /Termination_Count),2) AS Termination_Rate
FROM
      (
SELECT
        department ,
        COUNT(*) AS Total_Count,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS Termination_Count
        FROM Human_Resources
		WHERE  Age >=18
		GROUP BY  department
        ) 
AS Turnover_Subquery
        ORDER BY Termination_Rate DESC;
        
        
								/* DISTRIBUTION OF EMPLOYEES BY STATE */
SELECT
		location_state,
        COUNT(*) AS Location_Count
		FROM Human_Resources
		WHERE  Age >=18 
		GROUP BY location_state
        ORDER BY Location_Count DESC;
        
                             /*CHANGE OF EMPLOYEES COUNT OVER TIME BASED ON HIRE NAD TERM DATE*/
                             
SELECT
		Hire_Year,
        Hires,
        Terminations,
       ( Hires - Terminations ) AS Net_Change,
       ROUND(( Hires - Terminations )/ Hires*100,2) AS Net_Change_Percentage
       FROM
       (
SELECT
      YEAR(hire_date) AS Hire_Year,
      COUNT(*) AS Hires,
      SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS  Terminations
      FROM Human_Resources
      WHERE  Age >=18 
	  GROUP BY  Hire_Year
      ) AS Net_Subquery
      ORDER BY Hire_Year ASC;
       
								/*TENURE DISTRIBUTION FOR EACH DEPARTMENT*/
                                
SELECT 
        department,
		ROUND(AVG(DATEDIFF(termdate,hire_date))/365,0) AS Tenure_Average
		FROM Human_Resources
		WHERE  Age >=18 AND termdate<= curdate() AND termdate IS NOT NULL
       GROUP BY department ;
        
                             /*GENDER DISTRIBUTION ACROSS VARIOUS DEPARTMENTS */
                             
SELECT 
      department,
      gender,
      COUNT(*) AS Total_Count
	  FROM  Human_Resources
      WHERE  Age >=18 AND termdate IS NOT NULL
      GROUP BY  department, gender
      ORDER BY  department;