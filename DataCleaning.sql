select*
from Portfolio_project..Sheet1$

--STANDARDIZE DATE FORMAT

select SaleDate,CONVERT(date,SaleDate)
from Portfolio_project..Sheet1$

alter table Sheet1$
Add SaleDateConverted Date;

update Sheet1$
set SaleDateConverted=CONVERT(date,SaleDate)

select SaleDateConverted
from Portfolio_project..Sheet1$

--Populate property address data

select *
from Portfolio_project..Sheet1$
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_project..Sheet1$  a
join Portfolio_project..Sheet1$ b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--updating the table with populated address column

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_project..Sheet1$  a
join Portfolio_project..Sheet1$ b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--finally checking if the update was successful or not if it shows the table empty for 
--(a.PropertyAddress is null)then it is working fine


select a.PropertyAddress
from Portfolio_project..Sheet1$  a
where a.PropertyAddress is null

--Breaking out address into individual columns(Address,city,state)

select PropertyAddress
from Portfolio_project..Sheet1$

select 
--parsing through first index till encountering a comma-1(to not include the comma in the final result
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
--parsing through first comma+1 index till the end of the string i.e. LEN of the string
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as City
from Portfolio_project..Sheet1$

alter table Sheet1$
add PropertySplitAddress nvarchar(255);

update Sheet1$
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


alter table Sheet1$
add PropertySplitCity nvarchar(255);

update Sheet1$
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

select*
from Portfolio_project..Sheet1$

--doing the same but for owner address with PARSENAME function an easier method compared to substrings

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from Portfolio_project..Sheet1$

alter table Sheet1$
add OwnerSplitAddress nvarchar(255);

update Sheet1$
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)


alter table Sheet1$
add OwnerSplitCity nvarchar(255);

update Sheet1$
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table Sheet1$
add OwnerSplitState nvarchar(255);

update Sheet1$
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)

select*
from Sheet1$

--change Y and N to yes and no in SoldAsVacant

select distinct (SoldAsVacant) ,count(SoldAsVacant)
from Portfolio_project..Sheet1$
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N'then 'No'
	else SoldAsVacant
	end
from Portfolio_project..Sheet1$

--finally updating the table with the corrections made to Y and N
update Portfolio_project..Sheet1$
set SoldAsVacant=case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N'then 'No'
	else SoldAsVacant
	end

--Removing duplicates
 
 WITH RowNumCTE AS(
 select *,
 ROW_NUMBER() over(
 partition by 
 parcelId,
 PropertyAddress,
 SalePrice,
 SaleDate,
 LegalReference
 order by UniqueID
 )  row_num
 from Portfolio_project..Sheet1$
 
 )
 --finally deleting the duplicates

Delete 
from RowNumCTE
where row_num>1

--Finally checking if duplicates are deleted or not **comment the delete function and then select from the cte to the end to see the final result

select* 
from RowNumCTE
where row_num>1
order by PropertyAddress


--Delete unused columns

select *
from Portfolio_project..Sheet1$

ALTER TABLE Portfolio_project..Sheet1$
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Portfolio_project..Sheet1$
DROP COLUMN SaleDate


