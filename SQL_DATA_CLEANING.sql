-- Cleaning data in SQL
select * from NashvilleHousing

--standardize Date Format

select SaleDate,CONVERT(date,SaleDate),Sale_Date_converted
from NashvilleHousing

Alter table NashvilleHousing
add Sale_Date_converted date

update NashvilleHousing
set Sale_Date_converted=CONVERT(date,SaleDate)

--Populate Property Address Data
select parcelID,PropertyAddress
from NashvilleHousing
where PropertyAddress is null

--select * from NashvilleHousing
--order by ParcelID

select a.ParcelID,a.PropertyAddress,a.[UniqueID ],  b.ParcelID,b.PropertyAddress,b.[UniqueID ],ISNULL(a.propertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress=ISNULL(a.propertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--breaking out property address into individual columns (address, city, state)

select PropertyAddress from NashvilleHousing

select 
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))
from NashvilleHousing

alter table NashvilleHousing
add property_spilt_address Nvarchar(255),
Property_spilt_city Nvarchar(255)

update NashvilleHousing
set 
property_spilt_address=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1),
Property_spilt_city=SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))


--breaking out Owner address into individual columns ( address, city, state)


select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table nashvillehousing 
add 
Owner_split_address Nvarchar(255),
Owner_split_city Nvarchar(255),
Owner_split_state Nvarchar(255)

update NashvilleHousing
set
Owner_split_address=PARSENAME(replace(OwnerAddress,',','.'),3),
Owner_split_city=PARSENAME(replace(OwnerAddress,',','.'),2),
Owner_split_state=PARSENAME(replace(OwnerAddress,',','.'),1)


-- change Y and N to Yes and NO in SOld as Vacant Column
select distinct(soldasvacant),COUNT(soldasvacant)
from NashvilleHousing
group by soldasvacant

select soldasvacant,
case
	when 
		soldasvacant='Y' then 'Yes'
	when 
	    soldasvacant='N' then 'No'
		Else soldasvacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant=
case
	when 
		soldasvacant='Y' then 'Yes'
	when 
	    soldasvacant='N' then 'No'
		Else soldasvacant
		

--Remove Duplicates
With ROWNUMCTE AS(
select *,
	ROW_NUMBER()over (
	Partition by parcelID,
	propertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
			UniqueID
			) Row_Num
from NashvilleHousing )

delete
from ROWNUMCTE
where Row_Num>1
--order by PropertyAddress

--delete unused columns

alter table NashvilleHousing
drop column owneraddress,taxdistrict,propertyaddress 

alter table NashvilleHousing
drop column saledate