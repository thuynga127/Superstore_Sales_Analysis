 SELECT DISTINCT [W_SALES_REV_F].[Product_ID],
[W_SALES_REV_F].[Product_Name], [W_SALES_REV_F].[Category], [W_SALES_REV_F].[Subcategory]
INTO W_PRODUCT_D
FROM [dbo].[W_SALES_REV_F];



select * from [dbo].[W_PRODUCT_D];

select * from [dbo].[W_SALES_REV_F];

select * from W_CUSTOMER_D


SELECT DISTINCT [W_SALES_REV_F].[Customer_ID],
[W_SALES_REV_F].[Customer_Name], [W_SALES_REV_F].[Segment]
INTO W_CUSTOMER_D
FROM [dbo].[W_SALES_REV_F]

SELECT DISTINCT [W_SALES_REV_F].[Postal_Code],
[W_SALES_REV_F].[Country], [W_SALES_REV_F].[State], [W_SALES_REV_F].[City] 
INTO W_ADDRESS_D
FROM [dbo].[W_SALES_REV_F]


select * from W_ADDRESS_D

drop table W_ADDRESS_D




DECLARE @StartDate  date = '20150101';
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate));
;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    [Date]        = CONVERT(date, d),
    [Day]          = DATEPART(DAY,       d),
    [DayName]      = DATENAME(WEEKDAY,   d),
    [Week]         = DATEPART(WEEK,      d),
    [ISOWeek]      = DATEPART(ISO_WEEK,  d),
    [DayOfWeek]  = DATEPART(WEEKDAY,   d),
    [Month]        = DATEPART(MONTH,     d),
    [MonthName]   = DATENAME(MONTH,     d),
    [QuarterNo]     = DATEPART(Quarter,   d),
	[Quarter] = DATENAME(QUARTER, d),
    [Year]         = DATEPART(YEAR,      d),
    [FirstOfMonth] = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    [LastOfYear]  = DATEFROMPARTS(YEAR(d), 12, 31),
    [DayOfYear]   = DATEPART(DAYOFYEAR, d)
  FROM d
),
dim AS
(
  SELECT
    [Date], 
	[PERIOD_WID] = CONVERT(CHAR(8), CONVERT(int,[YEAR])*10000 + CONVERT(int, [MONTH])*100 + CONVERT(INT,[DAY])),
    [Day],
    [DaySuffix]        = CONVERT(char(2), CASE WHEN [Day] / 10 = 1 THEN 'th' ELSE 
                            CASE RIGHT([Day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
                            WHEN '3' THEN 'rd' ELSE 'th' END END),
    [DayName],
    [DayOfWeek],
    [DayOfWeekInMonth] = CONVERT(tinyint, ROW_NUMBER() OVER 
                            (PARTITION BY [FirstOfMonth], [DayOfWeek] ORDER BY [Date])),
    [DayOfYear],
    [Week],
    [ISOweek],
    [FirstOfWeek]      = DATEADD(DAY, 1 - [DayOfWeek], [Date]),
    [LastOfWeek]       = DATEADD(DAY, 6, DATEADD(DAY, 1 - [DayOfWeek], [Date])),
    [WeekOfMonth]     = CONVERT(tinyint, DENSE_RANK() OVER 
                            (PARTITION BY [Year], [Month] ORDER BY [Week])),
    [Month],
    [MonthName],
    [FirstOfMonth],
    [LastOfMonth]      = MAX([Date]) OVER (PARTITION BY [Year], [Month]),
    [FirstOfNextMonth] = DATEADD(MONTH, 1, [FirstOfMonth]),
    [LastOfNextMonth] = DATEADD(DAY, -1, DATEADD(MONTH, 2, [FirstOfMonth])),
	[MonthYearSort] = CONVERT(char(4), [Year]) + CONVERT(char(2), CONVERT(char(8), [Date], 101)),
    [QuarterNo],
	[Quarter],
    [FirstOfQuarter]   = MIN([Date]) OVER (PARTITION BY [Year], [Quarter]),
    [LastOfQuarter]    = MAX([Date]) OVER (PARTITION BY [Year], [Quarter]),
    [Year],
    [ISOYear]         = [Year] - CASE WHEN [Month] = 1 AND [ISOweek] > 51 THEN 1 
                            WHEN [Month] = 12 AND [ISOweek] = 1  THEN -1 ELSE 0 END,      
    [FirstOfYear]      = DATEFROMPARTS([Year], 1,  1),
    [LastOfYear], 
	[IsWeekend]          = CASE WHEN [DayOfWeek] IN (CASE @@DATEFIRST WHEN 1 THEN 6 WHEN 7 THEN 1 END,7) 
                            THEN 1 ELSE 0 END
  FROM src
)
SELECT * INTO [dbo].[W_CALENDAR_D] FROM dim
  ORDER BY [Date]
  OPTION (MAXRECURSION 0);




