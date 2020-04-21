-- 1). ROW_NUMBER() to select the top 3
SELECT 
  rownumber, 
  id_var, 
  num_var
FROM 
(
  SELECT 
    ROW_NUMBER() OVER (PARTITION BY id_var ORDER BY num_var DESC) AS rownumber, 
    tab.*
  FROM cur_table			tab	
)	dat
WHERE rownumber <= 3
ORDER BY id_var, rownumber

-- 2) Compute the length of consecutive days 
SELECT 
  id_var, 
  gen_var,
  MIN(date_var) AS start_dt,	
  MAX(date_var) as end_dt, 
  DATEDIFF(day, MIN(date_var), MAX(date_var)) + 1 AS consecutive_length
  --- Use the following if working in other databases like Orace, Netezza 
  -- MAX(new_dat_var) - MIN(new_dat_var) + 1 AS cur_length
FROM
(
  SELECT	
    dat2.*, 
    DATEADD(DAY, -1*rownumber, date_var) AS starting_count_dt
    --- new_dat_var - rownumber AS starting_count_dt
  FROM 
  (
    SELECT  
      dat.*, 
      ROW_NUMBER() OVER (PARTITION BY id_var ORDER BY date_var) AS rownumber
    FROM 
      cur_table			  dat
  ) dat2
) dat3
GROUP BY id_var, gen_var, starting_count_dt
ORDER BY id_var, start_dt

-- 3) WITH statement to break down complex queries
WITH 
  output_table_with_RowNumber AS (
    SELECT  
      dat.*, 
      ROW_NUMBER() OVER (PARTITION BY id_var ORDER BY date_var) AS rownumber
    FROM 
      cur_table                         dat
  ), 
	
  output_table_with_grouping_var AS (
    SELECT 
      dat.*, 
      DATEADD(DAY, -1*rownumber, date_var) AS starting_count_dt
    FROM output_table_with_RowNumber    dat
  )
SELECT 
  id_var, 
  gen_var,
  MIN(date_var) AS start_dt,	
  MAX(date_var) as end_dt, 
  DATEDIFF(day, MIN(date_var), MAX(date_var)) + 1 AS consecutive_length
FROM
  output_table_with_grouping_var 
GROUP BY id_var, gen_var, starting_count_dt
ORDER BY id_var, start_dt


-- 4) Aggregated report 
SELECT
  id_var,
  gen_var,
  ---- concatenated with comma in between 
  STRING_AGG(date_var, ',') WITHIN GROUP (ORDER BY date_var) AS concat_dates
  ---- also works for the num_var
  -- STRING_AGG(num_var, ',') WITHIN GROUP (ORDER BY date_var) AS concat_nums
FROM
  cur_table
GROUP BY id_var, gen_var
ORDER BY id_var













