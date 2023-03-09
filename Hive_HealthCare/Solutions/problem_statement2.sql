-- Active: 1671690241285@@127.0.0.1@3308@healthcare

-- Question 1:

WITH count_prescription AS
( Select Ph.PharmacyID "PharmacyId", Count(Pr.prescriptionId) AS "Count_Prescription", addressID 
FROM Pharmacy Ph 
JOIN Prescription Pr ON Ph.pharmacyID = Pr.pharmacyID
AND Pr.prescriptionID IN
(Select Pr.prescriptionID FROM Prescription Pr
INNER JOIN Contain C ON Pr.prescriptionID = C.prescriptionID
group by Pr.prescriptionID having SUM(C.quantity) > 100)
GROUP BY Ph.pharmacyID),
 
count_pharmacy AS (
Select A.city "City", A.addressID, COUNT(pharmacyID) AS "Count_Pharmacy" 
FROM Address A 
JOIN Pharmacy P ON A.addressID = P.addressID
GROUP BY A.city, A.addressID)

Select City, Sum(Count_Pharmacy) "Pharmacy_Count" , Sum(Count_Prescription) "Prescription_Count", Sum(Count_Pharmacy) / Sum(Count_Prescription) "Ratio"
FROM count_pharmacy as cph
JOIN count_prescription as cps
ON cph.addressID = cps.addressID
GROUP BY City
ORDER BY Ratio desc
LIMIT 30
;

-- Question 2:
with cte_table as 
(select  a.`city` as 'City', d.`diseaseID` as 'disease_Id', count(t.`patientID`) as "Number of patients" from disease d 
                        join treatment t on d.`diseaseID` = t.`diseaseID` 
                        join prescription p on t.`treatmentID` = p.`treatmentID`
                        join pharmacy ph on ph.`pharmacyID` = p.`pharmacyID`
                        join `address` a on a.`addressID` = ph.`addressID`
where a.state like "%AL%"
group by a.`city`, d.`diseaseID`)
select * from cte_table c1
where `Number of patients` = (select max(`Number of patients`) from cte_table c2 where c1.`city` = c2.`city`);

-- Question 3



-- Question 4:
with cte_table as(
select d.`diseaseID` as "disease_Id", pe.`addressID` , count(p.`patientID`) as "Number of Patients with same disease in same address" 
       from `disease` d join `treatment` t on d.`diseaseID` = t.`diseaseID` 
                        join `Patient` p on p.`patientID` = t.`patientID`
                        join `person` pe on pe.`personID` = p.`patientID`
group by d.`diseaseID`, pe.`addressID`
having(count(p.`patientID`) > 1)
)select * from cte_table;

-- Question 5:
with cte_table as(
select  a.`state`, count(t.`treatmentID`) "No. of treatments", count(c.`claimID`) as  "No. of Claims", 
count(t.`treatmentID`) / count(c.`claimID`) as "Treatment : Claim" 
FROM address a NATURAL JOIN person p
LEFT JOIN treatment t ON p.`personID`=t.`patientID`
LEFT JOIN claim c on t.`claimID` = c.`claimID`
WHERE t.`date` BETWEEN '2021-04-01' AND '2022-03-31'
group by a.`state`)
select * from cte_table;
