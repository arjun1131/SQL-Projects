-- Select all entries from Housing Table
SELECT * FROM Projects..Housing_Data

-- Standardizing Sale Date Column
select SaleDate , convert (date , SaleDate)
from Projects..Housing_Data

update Projects..Housing_Data
set SaleDate = convert (date , SaleDate)

alter table Projects..Housing_Data
add ConvertedSaleDate Date

update Projects..Housing_Data
set ConvertedSaleDate = convert (date , SaleDate)

select SaleDate , ConvertedSaleDate
from Projects..Housing_Data

-- Populate Address Data
select *
from Housing_Data
--where PropertyAddress is null
order by ParcelID

select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing_Data a
join Housing_Data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing_Data a
join Housing_Data b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Seperating Address into Individual Columns(Address, City , State)

select PropertyAddress
from Housing_Data
--where PropertyAddress is null
--order by ParcelID


select 
substring(PropertyAddress ,1, charindex(',',PropertyAddress)- 1)as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+ 1, len(PropertyAddress)) as City
from Housing_Data

alter table Housing_Data
add PropertySplitAddress varchar(255)

update Housing_Data
set PropertySplitAddress = substring(PropertyAddress ,1, charindex(',',PropertyAddress)- 1)

alter table Housing_Data
add PropertySplitCity varchar(255)

update Housing_Data
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+ 1, len(PropertyAddress))

select PropertySplitAddress , PropertySplitCity
from Housing_Data

--Split Owner Address

select OwnerAddress 
from Housing_Data

select 
parsename(replace(OwnerAddress,',','.') , 3) as OwnerAddress,
parsename(replace(OwnerAddress,',','.') , 2) as OwnerCity,
parsename(replace(OwnerAddress,',','.') , 1) as OwnerState
from Housing_Data

alter table Housing_Data
add OwnerSplitAddress varchar(255)

update Housing_Data
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.') , 3)


alter table Housing_Data
add OwnerSplitCity varchar(255)

update Housing_Data
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.') , 2)

alter table Housing_Data
add OwnerSplitStates varchar(255)

update Housing_Data
set OwnerSplitStates = parsename(replace(OwnerAddress,',','.') , 1)

--Change Y & N to Yes & No in 'SoldAsVacant' field

select distinct(SoldAsVacant),count(SoldAsVacant) as VacantCount
from Housing_Data
group by SoldAsVacant
order by count(SoldAsVacant)

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from Housing_Data

update Housing_Data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from Housing_Data


-- Remove Duplicates

with RowNoCTE as (
select * ,
	ROW_NUMBER() over(
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 order by
						UniqueID) row_no
from Housing_Data
--order by ParcelID
)

select *
from RowNoCTE
where row_no > 1
order by PropertyAddress

select * from Housing_Data


-- Delete Unused Columns

select * from Housing_Data

alter table Housing_Data
drop column OwnerAddress, PropertyAddress, TaxDistrict

alter table Housing_Data
drop column SaleDate