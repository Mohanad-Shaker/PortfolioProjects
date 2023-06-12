/*
Cleaning Data in SQL Queries
*/

Select *
From [Portfolio Project 2].dbo.NashvilleHousing


-- Standardize Date Format

alter table NashvilleHousing
add saledateupdated date

update NashvilleHousing
set saledateupdated = convert(date,SaleDate)


-- Populate Property Address data

select table1.PropertyAddress, table1.ParcelID , table2.PropertyAddress , table2.ParcelID , ISNULL(table1.PropertyAddress,table2.PropertyAddress)
from [Portfolio Project 2]..NashvilleHousing table1
join [Portfolio Project 2]..NashvilleHousing table2
	on table1.PropertyAddress = table2.PropertyAddress
	and table1.[UniqueID ] <> table2.[UniqueID ]
where table1.PropertyAddress is null

update table1
set PropertyAddress = ISNULL(table1.PropertyAddress,table2.PropertyAddress)
from [Portfolio Project 2]..NashvilleHousing table1
join [Portfolio Project 2]..NashvilleHousing table2
	on table1.PropertyAddress = table2.PropertyAddress
	and table1.[UniqueID ] <> table2.[UniqueID ]
where table1.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [Portfolio Project 2]..NashvilleHousing

select
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) - 1),
SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
from [Portfolio Project 2]..NashvilleHousing


alter table NashvilleHousing
add PropertyCity nvarchar(255)

alter table NashvilleHousing
add PropertyState nvarchar(255)

update NashvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) - 1)

update NashvilleHousing
set PropertyState = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



select OwnerAddress
from [Portfolio Project 2]..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from [Portfolio Project 2]..NashvilleHousing

alter table NashvilleHousing
add owneradd nvarchar(255)

alter table NashvilleHousing
add ownercity nvarchar(255)

alter table NashvilleHousing
add ownerstate nvarchar(255)

update NashvilleHousing
set owneradd = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

update NashvilleHousing
set ownercity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

update NashvilleHousing
set ownerstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant) ,count(SoldAsVacant) countSoldAsVacant
from [Portfolio Project 2]..NashvilleHousing
group by SoldAsVacant
order by countSoldAsVacant

update NashvilleHousing
set SoldAsVacant = case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end


-- Remove Duplicates

with remdup as (
select *,ROW_NUMBER() OVER (
		 PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from [Portfolio Project 2]..NashvilleHousing
)
select *
From remdup
Where row_num > 1
Order by PropertyAddress
-- we then delete the duplicate rows in the CTE
--delete
--From remdup
--Where row_num > 1



-- Delete Unused Columns

select *
from [Portfolio Project 2]..NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict