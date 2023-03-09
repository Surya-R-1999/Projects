-- Active: 1671690241285@@127.0.0.1@3308@healthcare

-- Question 1:

with cte_patients as 
(select patientID, ssn, dob, floor(DATEDIFF(CURDATE(),dob)/365.25) "Age" from patient)
select c.patientID, c.Age , t.date as 'treatment date', case when c.age between 0 and 15 then 'Children'
                             when c.age between 15 and 24 then 'Youth'
                             when c.age between 25 and 64 then 'Adults'
                             when c.age > 64 then 'Seniors'
                             else 'Invalid Age'
                             end as 'age category'
from cte_patients c join treatment t on c.`patientID`  = t.`patientID`
where year(t.date) = 2022;

-- Question 2:

select disease_Id,male_count, female_count, (male_count / female_count) as 'ratio' from 
(with cte_table as
(select d.`diseaseID` as 'disease_Id',pe.`gender` as 'Gender',count(*) as 'Count'  
from `disease` d join `treatment` t on d.`diseaseID` = t.`diseaseID` 
                 join `patient` p on p.`patientID` = t.`patientID`
                 join `person` pe on pe.`personID` = p.`patientID`
group by d.`diseaseID`,pe.`gender`)
SELECT `disease_ID`,
       SUM(CASE WHEN `Gender` = 'male' THEN `Count` END) AS 'male_count',
       SUM(CASE WHEN `Gender` = 'female' THEN `Count` END) AS 'female_count'
FROM cte_table
GROUP BY disease_ID) as `tab`
order by 4 desc;

-- Question 3:

with cte_table2 as
(select p.`gender` as 'Gender', c.`claimID` as 'Claims', t.`treatmentID` as 'treatments' 
FROM person p join treatment t on p.`personID` = t.`patientID`
LEFT JOIN claim c on t.`claimID` = c.`claimID`
)
select `Gender`, count(`Claims`) as 'Total Number of Claims', 
count(`treatments`) as "Total Number of treatments" , 
count(`treatments`)/count(`Claims`) as 'Ratio'
from cte_table2
group by `Gender`;


-- Question 4:

with cte_table3 as(
select p.`pharmacyID`as 'pharmacy_ID', 
count(m.`medicineID`) as "Total number of Medicines",
sum(m.`maxPrice`) as "Total Retail Price",
sum(m.`maxPrice` - (k.`discount` * 0.01)) as "Total Price of Medicines after discount"
from pharmacy p 
join `keep` k on p.`pharmacyID` = k.`pharmacyID`
join medicine m on m.`medicineID` = k.`medicineID`
where p.`pharmacyID` = k.`pharmacyID`
group by p.`pharmacyID`) 
select * from cte_table3;


-- Question 5:

select p.`pharmacyID`, max(c.quantity) as "maximum number of medicines", min(c.quantity) as "minimum number of medicines",
round(AVG(c.quantity),0) as "average number of medicines"
from pharmacy p join prescription pr on p.`pharmacyID` = pr.`pharmacyID`
join contain c on pr.`prescriptionID` = c.`prescriptionID`
group by p.`pharmacyID`;
