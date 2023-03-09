/**
Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine 
prescribed in 2022, total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of 
hospital-exclusive medicine to the total medicine prescribed in 2022.
Order the result in descending order of the percentage found. 
**/
with cte as
(select Ph.pharmacyID, Ph.pharmacyName, c.quantity, m.hospitalExclusive
from treatment T join prescription Pr on t.treatmentID = pr.treatmentID
join pharmacy ph on ph.pharmacyID = pr.pharmacyID
join contain c on pr.prescriptionID = c.prescriptionID
join medicine m on m.medicineID = c.medicineID
where year(T.date)=2022)
select pharmacyID, pharmacyName, sum(quantity) as TotalQuantity, 
sum(if(hospitalExclusive='S',quantity,0)) as HospitalExclusive_TotalQuantity, 
round(sum(if(hospitalExclusive='S',quantity,0))/sum(quantity),2) as Percentage
from cte
group by pharmacyID,pharmacyName; 

/**
Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. 
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. 
Assist Sarah by creating a report as per her requirement.
**/
With cte AS (
	Select state, patientId, count(treatmentId) "Count_Treatments",
	count(Case When C.claimId is Null THEN 1 END) "Count_Treatments_Unclaimed"
	From Address A
	Join Person Pr On Pr.addressId = A.addressId
	Join Treatment T On T.patientId = pr.personId
	Left Join Claim C On T.claimID = C.claimId
	Group By state, patientId
	Order By state, patientId)
Select state, sum(Count_Treatments_Unclaimed) "Total Unclaimed Treatments", sum(count_treatments) "Total Treatments",
	round((sum(Count_Treatments_Unclaimed)/sum(Count_Treatments)) * 100, 2) "Percentage_Unclaimed"
From cte 
Group By state; 

/*
Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases by the patients 
of that state in the year 2022. 
*/
With cte_table as (
Select state, diseaseName, count(treatmentId) "treatment_cnt"
From Address A
Right Join Person Pr On Pr.addressId = A.addressId
Right Join Treatment T On T.patientId = pr.personId
Join Disease D On D.diseaseId = T.diseaseId
Where year(T.date) = 2022
Group By state,diseaseName
Order By state, treatment_cnt Desc)
SELECT DISTINCT state, FIRST_VALUE(`diseaseName`) OVER(PARTITION BY state) 'MostTreatedDisease',
FIRST_VALUE(treatment_cnt) OVER(PARTITION BY state) 'NoOfTreatments',
LAST_VALUE(`diseaseName`) OVER(PARTITION BY state) 'LeastTreatedDisease',
LAST_VALUE(treatment_cnt) OVER(PARTITION BY state) 'NoOfTreatments'
FROM cte_table;

/*
Problem Statement 4: 
Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, in each city. 
Generate a report that shows each city that has 10 or more registered people belonging to it and the number of patients 
from that city as well as the percentage of the patient with respect to the registered people.
*/
SELECT city, COUNT(`personID`) 'noOfPatients',ROUND(COUNT(`patientID`)/COUNT(`personID`)*100,2) "Percentage"
FROM address
INNER JOIN person pe USING (`addressID`)
LEFT JOIN patient pa ON pe.`personID`=pa.`patientID`
GROUP BY city
HAVING noOfPatients >10;

/*
Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects. 
Find the top 3 companies using the substance in their medicine so that they can be informed about it.
*/
SELECT DISTINCT `companyName`, productName, substanceName
FROM medicine
WHERE `substanceName` LIKE '%ranitidina%'
Limit 3;

