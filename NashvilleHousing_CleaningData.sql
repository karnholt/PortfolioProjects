-- Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date, SaleDate)


-- Populate Property Address Data

Select *
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN  PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
-- where PropertyAddress is null
-- order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255);

Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity NVARCHAR(255);

Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning];



Select OwnerAddress
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning];

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning];

ALTER TABLE PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress NVARCHAR(255);

Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity NVARCHAR(255);

Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState NVARCHAR(255);

Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning];




-- Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
Group By SoldAsVacant
order by 2;


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

Update PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                PropertyAddress, 
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY 
                    UniqueID
) row_num
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
-- ORDER BY ParcelID
)
DELETE  
From RowNumCTE
WHERE row_num > 1
-- Order by PropertyAddress;

Select *  
From RowNumCTE
WHERE row_num > 1
Order by PropertyAddress;


-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning];

ALTER TABLE PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

