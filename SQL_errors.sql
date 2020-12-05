/** Create the toy datatable **/

CREATE TABLE UserLogin
    (
      [ID_Var] varchar(4), 
      [Num_Var] Numeric(10,2),
      [User_Var] varchar(3), 
      [Date_Var] Date, 
      [Location_Var] varchar(60)
    )
;

INSERT INTO UserLogin
    ([ID_Var], [Num_Var], [User_Var], [Date_Var], [Location_Var])
VALUES
    ('0155', 14.35, 'ABC', '20180603', 'California '),
    ('0155', 60.79, 'ABC', '20180601', 'Massachusetts'),
    ('0155', 0, 'ABC', '20180602', 'Nevada'),
    ('0155', 79.77, 'ABC', '20180929', NULL),
    ('0155', 122.82, 'ABC', '20180930', 'Arizona'),
    ('0180', 1810.47, 'DEF', '20160630', 'NYC'),
    ('0188', 732.62, 'GHI', '20160630', 'Massachusetts'),
    ('0188', 2782.89, 'GHI', '20160731', 'Illinois'),
    ('0188', 2989.38, 'GHI', '20160831', 'NYC'),
    ('0792', 721.36, 'JKL', '20160730', 'California'),
    ('0792', 817.94, 'JKL', '20160801', 'Massachusetts'),
    ('0792', 886.17, 'JKL', '20160831', 'NYC'),
    ('0792', 954.71, 'JKL', '20160930', 'Illinois'),
    ('0792', 1048.69, 'JKL', '20161031', 'NYC')
;


/** 1. User logins in both NYC and Illinois **/
SELECT 
  DISTINCT id_var, user_var  
FROM 
  userlogin 
WHERE 
  location_var IN ('NYC', 'Illinois')


/** 1.2 User logins in both NYC and Illinois -- logic AND **/
SELECT 
  id_var, user_var
FROM 
(
  SELECT 
    id_var, user_var, 
    SUM(CASE WHEN location_var = 'NYC' THEN 1 ELSE 0 END) AS nyc_cnt, 
    SUM(CASE WHEN location_var = 'Illinois' THEN 1 ELSE 0 END) AS illinois_cnt
  FROM 
    userlogin 
  GROUP BY id_var, user_var
) dat 
WHERE 
  nyc_cnt > 0 AND illinois_cnt > 0


/** 2. Return more information about login records -- GROUP BY **/
SELECT *
FROM 
(
  SELECT 
      id_var, user_var, date_var, location_var,
      SUM(CASE WHEN location_var = 'NYC' THEN 1 ELSE 0 END) AS nyc_cnt, 
      SUM(CASE WHEN location_var = 'Illinois' THEN 1 ELSE 0 END) AS illinois_cnt
  FROM 
      userlogin 
  GROUP BY id_var, user_var, date_var, location_var
) dat 
WHERE 
  nyc_cnt > 0 OR illinois_cnt > 0


/** 2.2 Return more information about login records -- PARTITION BY **/
SELECT *
FROM 
(
  SELECT 
    dat1.*, 
    SUM(CASE WHEN location_var = 'NYC' THEN 1 END) OVER (PARTITION BY id_var) AS nyc_cnt, 
    SUM(CASE WHEN location_var = 'Illinois' THEN 1 END) OVER (PARTITION BY id_var) AS illinois_cnt
  FROM 
    userlogin dat1
) dat2 
WHERE 
  nyc_cnt > 0 
    AND illinois_cnt > 0 
    AND location_var IN ('NYC', 'Illinois')



/** 3. User logins in California followed by Massachusetts **/
SELECT *
FROM 
(
  SELECT 
    dat.*, 
    LEAD(location_var) OVER (PARTITION BY id_var ORDER BY date_var) AS next_location
  FROM 
    userlogin   dat
) dat2 
WHERE 
  location_var = 'California' AND next_location = 'Massachusetts'

/** 4. User logins in NYC and in Year 2018 or Num_Var >= 1000 **/
SELECT *
FROM 
  userlogin 
WHERE 
  location_var = 'NYC'
    AND (YEAR(date_var) = '2018' 
    OR num_var >= 1000)


/** 5. NULL values **/
SELECT 
  COUNT(*) AS total_cnt, 
  COUNT(CASE WHEN location_var = 'California' THEN id_var END) AS california_CNT, 
  COUNT(CASE WHEN location_var <> 'California' THEN id_var END) AS non_california_CNT,
  COUNT(CASE WHEN location_var is NULL THEN id_var END) AS NULL_CNT
FROM 
  userlogin
WHERE id_var = '0155'

