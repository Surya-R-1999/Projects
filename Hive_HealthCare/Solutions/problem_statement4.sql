/**
Problem Statement 1: 
“HealthDirect” pharmacy finds it difficult to deal with the product type of medicine being displayed in numerical form, 
they want the product type in words. Also, they want to filter the medicines based on tax criteria. 
Display only the medicines of product categories 1, 2, and 3 for medicines that come under tax category I and medicines 
of product categories 4, 5, and 6 for medicines that come under tax category II.
**/
Select K.medicineID, M.taxCriteria,
	Case M.productType 
		 When 1 THEN "Generic"	 
		 When 2 THEN "Patent"
         When 3 THEN "Reference"
         When 4 THEN "Similar"
         When 5 THEN "New"
         When 6 THEN "Specific"
         When 7 THEN "Biological"
         When 8 THEN "Dinamized"
	End AS "ProductType"
From Keep K
JOIN Medicine M ON K.medicineID = M.medicineID
WHERE pharmacyID = 2301
AND (
	(M.productType IN (1,2,3) AND M.taxCriteria = 'I') 
	OR 
    (M.productType IN (4,5,6) AND M.taxCriteria = 'II'));

/**
Problem Statement 2
'Ally Scripts' pharmacy company wants to find out the quantity of medicine prescribed in each of its prescriptions.
Write a query that finds the sum of the quantity of all the medicines in a prescription and if the total quantity of medicine 
is less than 20 tag it as “low quantity”. If the quantity of medicine is from 20 to 49 (both numbers including) tag it as 
“medium quantity“ and if the quantity is more than equal to 50 then tag it as “high quantity”.
Show the prescription Id, the Total Quantity of all the medicines in that prescription, and the Quantity tag 
for all the prescriptions issued by 'Ally Scripts'.
3 rows from the resultant table may be as follows:
prescriptionID	totalQuantity	Tag
1147561399		43			Medium Quantity
1222719376		71			High Quantity
1408276190		48			Medium Quantity
**/
Select P.prescriptionId, SUM(C.quantity) "totalQuantity",
	CASE WHEN SUM(C.quantity) < 20 THEN "Low Quantity"
		 WHEN SUM(C.quantity) < 50 THEN "Medium Quantity"
         ELSE "High Quantity"
	END AS Tag
From Prescription P
Left Join Contain C ON P.prescriptionID = C.prescriptionID
WHERE pharmacyID = 3287
GROUP BY P.prescriptionID;

/**
Problem Statement 3: 
In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’ when the quantity exceeds 7500 
and ‘LOW QUANTITY’ when the quantity falls short of 1000. 
The discount is considered “HIGH” if the discount rate on a product is 30% or higher, 
and the discount is considered “NONE” when the discount rate on a product is 0%.
'Spot Rx' needs to find all the Low quantity products with high discounts and all the high-quantity products with no discount 
so they can adjust the discount rate according to the demand. 
Write a query for the pharmacy listing all the necessary details relevant to the given requirement.
Hint: Inventory is reflected in the Keep table.
**/
Select K.medicineID, productName, quantity, discount,
	   CASE WHEN quantity > 7500 THEN 'HIGH QUANTITY' 
			WHEN quantity < 1000 THEN 'LOW QUANTITY'
		END AS quantity_tag,
		CASE WHEN discount >= 30 THEN 'HIGH' 
			WHEN discount = 0 THEN 'NONE'
		END AS discount_tag
From Keep K
LEFT JOIN Medicine M ON K.medicineID = M.medicineID
WHERE pharmacyID = 1145 
AND (
	(quantity < 1000 AND discount >= 30)
    OR
    (quantity > 7500 AND discount = 0));

/**
Problem Statement 4
Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, hospital-exclusive medicines in the database. 
Where affordable medicines are the medicines that have a maximum price of less than 50% of the avg maximum price of all the medicines
in the database, and costly medicines are the medicines that have a maximum price of more than double the avg maximum price of 
all the medicines in the database.  Mack wants clear text next to each medicine name to be displayed that identifies the medicine as 
affordable or costly. The medicines that do not fall under either of the two categories need not be displayed.
Write a SQL query for Mack for this requirement.
**/
SET @AVG_MaxPrice = (Select AVG(M.maxPrice) From Medicine M);
Select @AVG_MaxPrice;
Select K.medicineId, M.productName, M.maxPrice, 
	CASE WHEN M.maxPrice < (0.5 * @Avg_MaxPrice) THEN "Affordable"
		 WHEN M.MaxPrice > (2 * @Avg_MaxPrice) THEN "Costly"
	END AS Medicine_Category
From Keep K
Join Medicine M ON K.medicineId = M.medicineId
Where K.pharmacyId = 2301
AND (M.maxPrice < (0.5 * @Avg_MaxPrice) OR M.MaxPrice > (2 * @Avg_MaxPrice));

/**
Problem Statement 5
The healthcare department wants to categorize the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.
Write a SQL query to list all the patient name, gender, dob, and their category.
**/
Select personName, gender, dob,
	CASE WHEN (dob >= '2005-01-01' AND gender = 'male') THEN 'YoungMale'
		 WHEN (dob >= '2005-01-01' AND gender = 'female') THEN 'YoungFemale'
         WHEN (dob < '2005-01-01' AND dob >= '1985-01-01' AND gender = 'male') THEN 'AdultMale'
         WHEN (dob < '2005-01-01' AND dob >= '1985-01-01' AND gender = 'female') THEN 'AdultFemale'
         WHEN (dob < '1985-01-01' AND dob >= '1970-01-01' AND gender = 'male') THEN 'MidAgeMale'
         WHEN (dob < '1985-01-01' AND dob >= '1970-01-01' AND gender = 'female') THEN 'MidAgeFemale'
         WHEN (dob < '1970-01-01' AND gender = 'male') THEN 'ElderMale'
         WHEN (dob < '1985-01-01' AND gender = 'female') THEN 'ElderFemale'
	END AS category
FROM Person Pr 
INNER JOIN Patient Pt ON Pt.patientID=Pr.personID