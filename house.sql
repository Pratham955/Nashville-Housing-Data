CREATE TABLE house(
UniqueID INTEGER,
ParcelID VARCHAR(25),
LandUse VARCHAR(50),
PropertyAddress VARCHAR(50),
SaleDate DATE,
SalePrice VARCHAR(10),
LegalReference VARCHAR(25),
SoldAsVacant VARCHAR(10),
OwnerName VARCHAR(75),
OwnerAddress VARCHAR(50),
Acreage NUMERIC,
TaxDistrict VARCHAR(50),
LandValue INTEGER,
BuildingValue INTEGER,
TotalValue INTEGER,
YearBuilt SMALLINT,
Bedrooms SMALLINT,
FullBath SMALLINT,
HalfBath SMALLINT
)

-- Removing characters "$" and "," in SalePrice value

UPDATE house
SET SalePrice = CASE  
     WHEN SalePrice LIKE '%,%' THEN REPLACE(REPLACE(SalePrice,'$',''),',','')
     ELSE SalePrice
     END

-- Changing the datatype of SalesPrice to INTEGER

ALTER TABLE house
ALTER SalePrice TYPE INTEGER
USING SalePrice::INTEGER

-- Updating Property Address data from existing ParcelID

UPDATE house a 
SET PropertyAddress = b.PropertyAddress
FROM house b
WHERE a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
AND a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking PropertyAddress in PropertySplitAddress, PropertySplitCity

ALTER TABLE house
ADD PropertySplitAddress VARCHAR(40)

UPDATE house
SET PropertySplitAddress = SPLIT_PART(PropertyAddress,',',1)

ALTER TABLE house
ADD PropertySplitCity VARCHAR(20)

UPDATE house
SET PropertySplitCity = SPLIT_PART(PropertyAddress,',',2)

------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking OwnerAddress in OwnerSplitAddress, OwnerSplitCity, OwnerSplitState

ALTER TABLE house
ADD OwnerSplitAddress VARCHAR(40)

UPDATE house
SET OwnerSplitAddress = SPLIT_PART(OwnerAddress,',',1)

ALTER TABLE house
ADD OwnerSplitCity VARCHAR(20)

UPDATE house
SET OwnerSplitCity = SPLIT_PART(OwnerAddress,',',2)

ALTER TABLE house
ADD OwnerSplitState VARCHAR(10)

UPDATE house
SET OwnerSplitState = SPLIT_PART(OwnerAddress,',',3)

------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in the "Sold as Vacant" field

UPDATE house
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END

------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

DELETE FROM house 
WHERE UniqueID IN 
( 
	WITH RowNumCTE AS
	(
		SELECT UniqueID,ParcelID,SaleDate,SalePrice,LegalReference, 
		ROW_NUMBER() OVER
			(	
				PARTITION BY ParcelID,SaleDate,SalePrice,LegalReference
			) row_num
		FROM house
	)
	SELECT UniqueID FROM RowNumCTE
	WHERE row_num > 1 
)

------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE house
DROP PropertyAddress,
DROP OwnerAddress

------------------------------------------------------------------------------------------------------------------------------------------------

-- Data Exploration

-- Top 10 years with the highest average value of sale price

SELECT YearBuilt, ROUND(AVG(SalePrice)) as AvgSalePrice
FROM house
GROUP BY YearBuilt
ORDER BY AverageValue DESC
LIMIT 10

-- Most preferred number of bedrooms

SELECT Bedrooms,COUNT(Bedrooms) AS Number_of_Bedrooms
FROM house
WHERE Bedrooms IS NOT NULL
GROUP BY Bedrooms
ORDER BY Number_of_Bedrooms DESC

-- Most preferred number of bathrooms

SELECT FullBath, COUNT(FullBath) AS Number_of_Bathrooms
FROM house
WHERE FullBath IS NOT NULL
GROUP BY FullBath
ORDER BY Number_of_Bathrooms DESC

--Top 10 land use with the highest average value of sale price

SELECT LandUse, AVG(SalePrice) as AvgSalePrice
FROM house
GROUP BY LandUse
ORDER BY AvgSalePrice DESC
LIMIT 10

-- Does the price of a house in a city affect the total value of a house

SELECT PropertySplitCity, ROUND(AVG(TotalValue)) as AvgTotalValue
FROM house
WHERE TotalValue IS NOT NULL
GROUP BY PropertySplitCity
ORDER BY AvgValue DESC

-- Check which month sold the most amount of houses

SELECT TO_CHAR(SaleDate, 'Month') AS MonthSold, COUNT(*) as NumHousesSold
FROM house
GROUP BY MonthSold
ORDER BY NumHousesSold DESC
