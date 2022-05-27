#Part 1 - Join CA tables with required fields, then WA tables with required fields

CREATE TABLE summit.ca_data SELECT cr.student_id, cr.last_name, cr.first_name, cr.site_name, cr.grade, cd.combined_race_ethnicity AS race_ethnicity, cd.gender, cd.has_iep 
FROM summit.ca_roster cr
INNER JOIN summit.ca_demographics cd
ON cr.student_id = cd.student_id
ORDER BY student_id ASC
;
SELECT * FROM summit.ca_data;

CREATE TABLE summit.wa_data SELECT wr.id AS student_id, wr.last_name, wr.first_name, wr.name AS site_name, wr.grade_level, wd.race_ethnicity, wd.gender, wd.iep 
FROM summit.wa_roster wr
INNER JOIN summit.wa_demographics wd
ON wr.id = wd.id
ORDER BY student_id ASC
;
SELECT * FROM summit.wa_data;

#Modify wa_data IEP field so data type matches CA_data, alter values to TRUE/FALSE

ALTER TABLE summit.wa_data MODIFY iep TEXT;

UPDATE summit.wa_data
SET
	iep = 'FALSE'
WHERE
	iep = 0;

UPDATE summit.wa_data
SET
	iep = 'TRUE'
WHERE
	iep = 1;
    
#Match column names across WA & CA tables, union both into one table 
    
ALTER TABLE summit.wa_data 
RENAME COLUMN grade_level TO grade;

ALTER TABLE summit.ca_data
RENAME COLUMN has_iep TO iep;

CREATE TABLE summit.summit_data
	SELECT * FROM summit.ca_data
		UNION
	SELECT * FROM summit.wa_data;

SELECT * FROM summit.summit_data;

#Check top entry Howardo Shenny for duplicates

SELECT * FROM summit.summit_data
WHERE site_name = 'SPS Tour';

SELECT * FROM summit.summit_data
WHERE first_name = 'Howardo'
AND 
last_name = 'Shenny';

UPDATE summit.summit_data
SET gender = 'M'
WHERE gender = 'X'
AND first_name = 'Howardo'
AND 
last_name = 'Shenny';

DELETE FROM summit.summit_data WHERE site_name = 'SPS Tour';

#Check for student_id duplicates

SELECT student_id, last_name, first_name, COUNT(*) AS count
FROM summit.summit_data
GROUP BY student_id
ORDER BY count DESC;

SELECT * FROM summit.summit_data;

#Part 2 - How many IEPS in each grade at each school

CREATE VIEW summit_iep AS
SELECT COUNT(iep) AS has_iep, grade, site_name FROM summit.summit_data
WHERE iep='TRUE'
AND
grade <> 0
GROUP BY site_name, grade
ORDER BY grade, site_name;

SELECT * FROM Summit.summit_iep;

#Export Part 1 to Excel worksheet to create tracker 


    
