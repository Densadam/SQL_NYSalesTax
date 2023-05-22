SELECT * FROM dbo.NYSaleTax;


-- Checks if there are any null values
SELECT *
FROM dbo.NYSaleTax
WHERE Taxable_Sales_and_Purchases IS NULL;


--Gets distinct description values that are also null values in Taxable_Sales_and_Purchases
SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY Description ORDER BY (SELECT 1)) AS rn
  FROM dbo.NYSaleTax
) AS subquery
WHERE rn = 1 AND Taxable_Sales_and_Purchases IS NULL;


--Check if there's a 0 in Taxable_Sales_and_Purchases column
SELECT *
FROM dbo.NYSaleTax
WHERE Taxable_Sales_and_Purchases = 0;


--Check if there's a F in Status column
SELECT *
FROM dbo.NYSaleTax
WHERE Status LIKE 'F';


--Check if there's a P in Status column
SELECT *
FROM dbo.NYSaleTax
WHERE Status LIKE 'P';


-- Checks if any duplicate rows
SELECT COUNT(*) AS DuplicateCount,
	Status,	
	Sales_Tax_Year,	
	Selling_Period,	
	Sales_Tax_Quarter,	
	Jurisdiction,	
	NAICS_Industry_Group,	
	Description,	
	Taxable_Sales_and_Purchases,	
	Jurisdiction_Sort_Order,	
	Row_Update_Indicator 
FROM dbo.NYSaleTax
GROUP BY Status,	
	Sales_Tax_Year,	
	Selling_Period,	
	Sales_Tax_Quarter,	
	Jurisdiction,	
	NAICS_Industry_Group,	
	Description,	
	Taxable_Sales_and_Purchases,	
	Jurisdiction_Sort_Order,	
	Row_Update_Indicator
HAVING COUNT(*) > 1;


--Creates new column named QuarterYear
ALTER TABLE dbo.NYSaleTax
ADD QuarterYear INT;


--Adds latest year to QuarterYear column
UPDATE dbo.NYSaleTax
SET QuarterYear = CAST(RIGHT(Sales_Tax_Year, 4) AS INT);


--Creates new column named QuarterMonth
ALTER TABLE dbo.NYSaleTax
ADD QuarterMonth VARCHAR(20);


--Adds the latest month to the QuarterMonth column
UPDATE dbo.NYSaleTax
SET QuarterMonth = SUBSTRING(Selling_Period, CHARINDEX('-', Selling_Period) + 2, LEN(Selling_Period));


--Creates new column named QuarterDate
ALTER TABLE dbo.NYSaleTax
ADD QuarterDate DATE;


--Merges QuarterYear and QuarterMonth into QuarterDate column
UPDATE dbo.NYSaleTax
SET QuarterDate = CONVERT(VARCHAR(10), 
    (CASE 
        WHEN QuarterMonth = 'February' THEN '02'
		WHEN QuarterMonth = 'May' THEN '05'
		WHEN QuarterMonth = 'August' THEN '08'
		WHEN QuarterMonth = 'November' THEN '11'
        -- Add mappings for other months here
        ELSE 'Unknown'
    END) + '/01/' + CAST(QuarterYear AS VARCHAR(4)));

--Drops unnecessary columns
ALTER TABLE dbo.NYSaleTax
DROP COLUMN  Status, Sales_Tax_Year, Selling_Period, Sales_Tax_Quarter, NAICS_Industry_Group, Jurisdiction_Sort_Order, QuarterYear, QuarterMonth;


--Sets the Row_Update_Indicator column as the Primary Key
ALTER TABLE dbo.NYSaleTax
ADD CONSTRAINT PK_NYSaleTax PRIMARY KEY (Row_Update_Indicator);


--Returns each description category
SELECT DISTINCT Description FROM dbo.NYSaleTax
ORDER BY Description;


--Returns rows that contain LIKE value
SELECT Jurisdiction, Description, Taxable_Sales_and_Purchases, Row_Update_Indicator, QuarterDate
FROM
    dbo.NYSaleTax
WHERE
    CASE
        WHEN Description LIKE '%Pharmaceutical and Medicine Manufacturing%' THEN 1
        ELSE 0
    END = 1;


--Returns rows that contain LIKE value
SELECT Jurisdiction, Description, Taxable_Sales_and_Purchases, Row_Update_Indicator, QuarterDate
FROM dbo.NYSaleTax
WHERE
    CASE
        WHEN Description LIKE '%Medical Equipment and Supplies Manufacturing%' THEN 1
        ELSE 0
    END = 1;

