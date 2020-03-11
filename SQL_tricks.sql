---- 1) COALESCE() to recode the NULL value to the character string MISSING
SELECT 
    ID_VAR, 
    NULL_VAR,
    COALESCE(NULL_VAR, 'MISSING') AS RECODE_NULL_VAR
FROM  
  CURRENT_TABLE    
ORDER BY ID_VAR

--- However, COALESCE() NOT WORK for Empty or NA string, instead, use CASE WHEN
SELECT 
  ID_VAR, 
  EMPTY_STR_VAR, 
  COALESCE(EMPTY_STR_VAR, 'MISSING') AS COALESCE_EMPTY_STR_VAR, 
  CASE WHEN EMPTY_STR_VAR = ' ' THEN 'EMPTY_MISSING' END AS CASEWHEN_EMPTY_STR_VAR, 
  
  NA_STR_VAR, 
  CASE WHEN NA_STR_VAR = 'NA' THEN 'NA_MISSING' END AS CASEWHEN_NA_STR_VAR
FROM 
  CURRENT_TABLE 
ORDER BY ID_VAR

--- 2) Running total/frequency
SELECT
  DAT.NUM_VAR, 
  SUM(NUM_VAR) OVER (PARTITION BY JOIN_ID) AS TOTAL_SUM,
  ROUND(CUM_SUM / SUM(NUM_VAR) OVER (PARTITION BY JOIN_ID), 4) AS CUM_FREQ
FROM 
(
  SELECT 
	 T.*, 
	 SUM(NUM_VAR) OVER (ORDER BY NUM_VAR ROWS UNBOUNDED PRECEDING) AS CUM_SUM, 
	 CASE WHEN ID_VAR IS NOT NULL THEN '1' END AS JOIN_ID
  FROM CURRENT_TABLE    T
) DAT 	
ORDER BY CUM_FREQ

--- 3) Find the record having a number calculated by analytic functions (e.g., MAX) with out self-joining 
SELECT *
FROM 
(
  SELECT 
    DAT.*, 
    CASE WHEN (NUM_VAR = MAX(NUM_VAR) OVER (PARTITION BY ID_VAR)) THEN 'Y' ELSE 'N' END AS MAX_NUM_IND
  FROM 
    CURRENT_TABLE     DAT
) DAT2
WHERE MAX_NUM_IND = 'Y'

-- 4) Conditional where clause
SELECT 
  DAT.ID_VAR,
  DAT.SEQ_VAR,
  DAT.NUM_VAR,
  DATE_VAR1, 
  DATE_VAR2,
  TRUNC(DATE_VAR2) - TRUNC(DATE_VAR1) AS LAG_IN_DATES
FROM 
  CURRENT_TABLE      DAT 
WHERE
  (TRUNC(DATE_VAR2) - TRUNC(DATE_VAR1)) >= CASE WHEN SEQ_VAR IN (1,2,3) THEN 0 WHEN SEQ_VAR IN (4,5,6) THEN 1 ELSE 2 END 
ORDER BY ID_VAR, SEQ_VAR

--- 5) LAG() or LEAD() function
SELECT
 DAT.ID_VAR,
 DAT.SEQ_VAR,
 DAT.NUM_VAR,
 NUM_VAR - PREV_NUM AS NUM_DIFF	
FROM 
(
	SELECT 
	 T.*, 
	 LAG(NUM_VAR, 1, 0) OVER (PARTITION BY ID_VAR ORDER BY SEQ_VAR) AS PREV_NUM        
	FROM 
	 CURRENT_TABLE     T
)  DAT
ORDER BY ID_VAR, SEQ_VAR

--- 6) Read in SQL queries without copying and pasting 
-- SQL_FILE.sql
SELECT 
  *
FROM 
  CURRENT_TABLE   DAT
WHERE 
  ID_VAR IN ('ID_LIST')
ORDER BY ID_VAR, SEQ_VAR

--- python code
import pandas as pd            
def getSQL(sql_query, 
           place_holder_str,
           replace_place_holder_with,
           database_con):
    '''
    Args:
        sql_query: sql query file 
        place_holder_str: string in the original sql query that is to be replaced
        replace_place_holder_with: real values that should be put in 
        database_con: connection to the database 
    '''
    
    sqlFile = open(sql_query, 'r')
    sqlQuery = sqlFile.read()
    
    sqlQuery = sqlQuery.replace(place_holder_str, replace_place_holder_with)    
             
    df = pd.read_sql_query(sqlQuery, database_con)          
                
    database_con.close()

    return df              
            

seq12_df = getSQL('SQL_FILE.sql', 'ID_LIST', "','".join(['19228', '19272']), database_con=conn)



--- bonus: use REGEXP_INSTR for regular expression
-- Find and extract numbers between 0 - 9 that consecutively happens 5 times
SELECT
  SUBSTRING(LONG_TEXT, REG_IDX, REG_IDX+5) AS NUMBER_LIST_FOUND
FROM 
(
  SELECT 
    REGEXP_INSTR(LONG_TEXT, '[0-9]{5}') AS REG_IDX, 
    LONG_TEXT
  FROM 
    BONUS
) DAT 