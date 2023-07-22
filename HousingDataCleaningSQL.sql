SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardizing date format
SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populating Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD NewAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET NewAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD NewCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET NewCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD NewOwnerAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD NewOwnerCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD NewOwnerState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Changing Y and N to 'Yes' and 'No' in 'Sold as Vacant' Field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing 
SET SoldAsVacant=
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Removing Duplicates 

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) ROW_NUM
FROM PortfolioProject..NashvilleHousing)

--DELETE 
--FROM RowNumCTE
--WHERE ROW_NUM>1

SELECT *
FROM RowNumCTE
WHERE ROW_NUM>1

--Delete Unused Columns
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing