-- cleaning data in SQL queries
select * from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------
-- Standadize date format
select SaleDate , convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = convert(Date, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

select SaleDateConverted , convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = convert(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data
select * from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress IS NULL
order By ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------------------------------------------
-- Breaking Out Property Address into Individual Columns ( address, City, State)
select PropertyAddress from PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add ProperySplitAddress NVarchar(255)
  

update PortfolioProject.dbo.NashvilleHousing
SET ProperySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add ProperySplitCity NVarchar(255)
  

update PortfolioProject.dbo.NashvilleHousing
SET ProperySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))

select * from PortfolioProject.dbo.NashvilleHousing

-- Breaking Out Owner Address into Individual Columns ( address, City, State)
select OwnerAddress from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress NVarchar(255)
  

update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity NVarchar(255)
  

update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState NVarchar(255)
  

update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

-------------------------------------------------------------------------------------------------------------------------------------

--change Y and N to Yes and No in 'Sold as vacant' field
Select Distinct (SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    ELSE SoldAsVacant
	                    END
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
select * from PortfolioProject.dbo.NashvilleHousing


With RowNumCTE AS(
Select *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select* from RowNumCTE
where row_num >1
order by PropertyAddress

Delete from RowNumCTE
where row_num >1
--order by PropertyAddress



-------------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns
select * from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate