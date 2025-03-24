/*

Cleaning Data in SQL Queries

*/


Select *
From [Portfolio Project]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
---CHANGING dATE FORMAT AND ADDING NEW COLUMN

Select saleDate, CONVERT(Date,SaleDate) AS saleDateConverted
From [Portfolio Project]..NashvilleHousing

Select *
From [Portfolio Project]..NashvilleHousing

--Update [Portfolio Project]..NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)


-- If it doesn't Update properly

--ALTER TABLE [Portfolio Project]..NashvilleHousing
--Add SaleDateConverted Date;

--Update [Portfolio Project]..NashvilleHousing
--SET SaleDateConverted = CONVERT(Date,SaleDate)

--Select saleDateConverted, CONVERT(Date,SaleDate)
--From [Portfolio Project]..NashvilleHousing
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


--ISNULL to check if there is a null value and replace it with the correct one assigned
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address --to get rid of the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Portfolio Project]..NashvilleHousing

--creating new column
ALTER TABLE [Portfolio Project]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [Portfolio Project]..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From [Portfolio Project]..NashvilleHousing





Select OwnerAddress
From [Portfolio Project]..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) ---changing comas into periods
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..NashvilleHousing


---Adding new address city columns and state
ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Portfolio Project]..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Portfolio Project]..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project]..NashvilleHousing



Update [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---run initial query again




-----------------------------------------------------------------------------------------------------------------------------------------------------------

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

From [Portfolio Project]..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

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

From [Portfolio Project]..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From [Portfolio Project]..NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
