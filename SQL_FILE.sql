
--- 6) Read in SQL queries without copying and pasting 
--- We want to extract only records for ID '19228' and '19272'
SELECT 
  *
FROM 
  CURRENT_TABLE   DAT
WHERE 
  ID_VAR IN ('ID_LIST')
ORDER BY ID_VAR, SEQ_VAR