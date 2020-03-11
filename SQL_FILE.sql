
--- 6) Read in SQL queries without copying and pasting 
--- We want to extract only records for ID '19228' and '19272' into R and Python, and we don't want to copy and paste the 
--- original SQL code because otherwise, it would be difficult for code update and maintainance. Here for demonstration, 
--- let's connect through ODBC
-- The trick here is to 
SELECT 
  *
FROM 
  CURRENT_TABLE   DAT
WHERE 
  ID_VAR IN ('ID_LIST')
ORDER BY ID_VAR, SEQ_VAR