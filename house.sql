-- CREATE TABLE house(
-- UniqueID INTEGER,
-- ParcelID VARCHAR(25),
-- LandUse VARCHAR(50),
-- PropertyAddress VARCHAR(50),
-- SaleDate DATE,
-- SalePrice VARCHAR(10),
-- LegalReference VARCHAR(25),
-- SoldAsVacant VARCHAR(10),
-- OwnerName VARCHAR(75),
-- OwnerAddress VARCHAR(50),
-- Acreage NUMERIC,
-- TaxDistrict VARCHAR(50),
-- LandValue INTEGER,
-- BuildingValue INTEGER,
-- TotalValue INTEGER,
-- YearBuilt SMALLINT,
-- Bedrooms SMALLINT,
-- FullBath SMALLINT,
-- HalfBath SMALLINT
-- )

-- Removing characters "$" and "," in SalePrice value
-- UPDATE house
-- SET SalePrice = CASE  
--      WHEN SalePrice LIKE '%,%' THEN REPLACE(REPLACE(SalePrice,'$',''),',','')
--      ELSE SalePrice
--      END

-- Changing the datatype of SalesPrice to INTEGER
-- ALTER TABLE house
-- ALTER SalePrice TYPE INTEGER
-- USING SalePrice::INTEGER

-- Updating Property Address data from existing ParcelID
-- UPDATE house a 
-- SET PropertyAddress = b.PropertyAddress
-- FROM house b
-- WHERE a.ParcelID = b.ParcelID
-- AND a.UniqueID <> b.UniqueID 
-- AND a.PropertyAddress IS NULL

-- ---------------------------------------------------------------------------
-- Breaking PropertyAddress in PropertySplitAddress, PropertySplitCity
-- ALTER TABLE house
-- ADD PropertySplitAddress VARCHAR(40)

-- UPDATE house
-- SET PropertySplitAddress = SPLIT_PART(PropertyAddress,',',1)

-- ALTER TABLE house
-- ADD PropertySplitCity VARCHAR(20)

-- UPDATE house
-- SET PropertySplitCity = SPLIT_PART(PropertyAddress,',',2)

-- ----------------------------------------------------------------------------
-- Breaking OwnerAddress in OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
-- ALTER TABLE house
-- ADD OwnerSplitAddress VARCHAR(40)

-- UPDATE house
-- SET OwnerSplitAddress = SPLIT_PART(OwnerAddress,',',1)

-- ALTER TABLE house
-- ADD OwnerSplitCity VARCHAR(20)

-- UPDATE house
-- SET OwnerSplitCity = SPLIT_PART(OwnerAddress,',',2)

-- ALTER TABLE house
-- ADD OwnerSplitState VARCHAR(10)

-- UPDATE house
-- SET OwnerSplitState = SPLIT_PART(OwnerAddress,',',3)

-- -----------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
-- UPDATE house
-- SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--      WHEN SoldAsVacant = 'N' THEN 'No'
--      ELSE SoldAsVacant
--      END

---------------------------------------------------------------------
-- Removing Duplicates
-- DELETE FROM house 
-- WHERE UniqueID IN 
-- ( 
-- 	WITH RowNumCTE AS
-- 	(
-- 		SELECT UniqueID,ParcelID,SaleDate,SalePrice,LegalReference, 
-- 		ROW_NUMBER() OVER
-- 			(	
-- 				PARTITION BY ParcelID,SaleDate,SalePrice,LegalReference
-- 			) row_num
-- 		FROM house
-- 	)
-- 	SELECT UniqueID FROM RowNumCTE
-- 	WHERE row_num > 1 
-- )

-- -----------------------------------------------------------------
-- Delete Unused Columns
-- ALTER TABLE house
-- DROP PropertyAddress,
-- DROP OwnerAddress

--Find the average value of a house by year
-- SELECT YearBuilt, ROUND(AVG(TotalValue)) as AverageValue
-- FROM house
-- GROUP BY YearBuilt
-- ORDER BY AverageValue DESC
-- LIMIT 10

--Average value of a house base on number of bedrooms and bathrooms
-- Select Bedrooms, FullBath, AVG(TotalValue) as AvgValue
-- From house
-- Group by Bedrooms, FullBath
-- Order by AvgValue Desc

--See the effect total acreage has on house value
-- Select Acreage, ROUND(AVG(TotalValue)) as AvgValue
-- From house
-- GROUP BY Acreage
-- Order by AvgValue Desc
-- LIMIT 10

-- Does the city a house is located have an effect on the total value of a house
-- SELECT PropertySplitCity, AVG(TotalValue) as AvgValue
-- FROM house
-- GROUP BY PropertySplitCity
-- ORDER BY AvgValue DESC

-- Check which month sold the most amount of houses
-- SELECT TO_CHAR(SaleDate, 'Month') AS MonthSold, COUNT(*) as NumHousesSold
-- FROM house
-- GROUP BY MonthSold
-- ORDER BY NumHousesSold DESC

-- Total Value vs Sold value
-- SELECT landuse,((SalePrice) - (TotalValue))*100.0/(TotalValue) AS Diff
-- FROM house
-- WHERE totalvalue is not null
-- GROUP BY landuse,SalePrice,TotalValue
-- ORDER BY Diff DESC

--LandType vs Total Value
-- SELECT LandUse, AVG(TotalValue) as AvgVal
-- FROM house
-- GROUP BY LandUse
-- ORDER BY AvgVal DESC