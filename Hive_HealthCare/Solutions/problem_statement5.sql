-- Active: 1671690241285@@127.0.0.1@3308@healthcare

-- Question1:

select pe.`personName` as "Name", round(DATEDIFF(CURDATE(), p.dob)/365.25) as "Age", count(t.`treatmentID`)
from person pe join patient p on pe.`personID` = p.`patientID`
join treatment t on p.patientId = t.patientId
group by pe.`personName`, round(DATEDIFF(CURDATE(), p.dob)/365.25)
order by 3 desc;

-- Question 2:

select disease_Id, male_count, female_count, (male_count / female_count) as 'ratio' from 
(with cte_table as
(select d.`diseaseID` as 'disease_Id',pe.`gender` as 'Gender', count(*) as 'Count'  
from `disease` d join `treatment` t on d.`diseaseID` = t.`diseaseID` 
                 join `patient` p on p.`patientID` = t.`patientID`
                 join `person` pe on pe.`personID` = p.`patientID`
where year(t.date) = 2021
group by d.`diseaseID`,pe.`gender`)
SELECT `disease_ID`,
       SUM(CASE WHEN `Gender` = 'male' THEN `Count` END) AS 'male_count',
       SUM(CASE WHEN `Gender` = 'female' THEN `Count` END) AS 'female_count'
FROM cte_table
GROUP BY disease_ID) as `tab`
order by 4 desc;

-- Question 3:
select `Disease`,  `Num of treatments`, `City` 
from(
with cte_table as(
select d.`diseaseID` as "Disease", count(t.`treatmentID`) as "Num of treatments", 
a.city as "City"
from `disease` d join `treatment` t on d.`diseaseID` = t.`diseaseID` 
                 join `patient` p on p.`patientID` = t.`patientID`
                 join `person` pe on pe.`personID` = p.`patientID`
                 join `address` a on a.`addressID` = pe.`addressID` 
group by d.`diseaseID`, a.city
order by d.`diseaseID`, count(t.`treatmentID`) desc)
select `Disease`, `Num of treatments`, `City` , 
row_number() over(partition by disease) as n from cte_table c) as tab
where n < 4;


-- Question 4:
-- with prescriptions_count as (
-- select ph.`pharmacyID`, count(pr.`prescriptionID`), t.`date` 
-- from pharmacy ph join prescription pr on ph.`pharmacyID` = pr.`pharmacyID`
-- join treatment t on t.`treatmentID` = pr.`treatmentID` 
-- join disease d on d.`diseaseID` = t.`diseaseID`
-- where year(t.date) between 2021 and 2022
-- group by ph.`pharmacyID`, t.`date`)


select ph.`pharmacyID`,d.`diseaseID`, 
case when year(t.date) = 2021 then (select count(`prescriptionID`) from prescription group by 


from pharmacy ph join prescription pr on ph.`pharmacyID` = pr.`pharmacyID`
join treatment t on t.`treatmentID` = pr.`treatmentID` 
join disease d on d.`diseaseID` = t.`diseaseID`
where year(t.date) between 2021 and 2022
;


select pr.`prescriptionID`, count(t.`date`) from 
prescription pr join treatment t 
on pr.`treatmentID` = t.`treatmentID`
group by pr.`prescriptionID`
having count(t.`date`) = 1
order by 1;


with cte_2021 as(
select ph.`pharmacyID` as "pid1", d.`diseaseID` as "did1", count(pr.`prescriptionID`) as "cnt_2021"
from pharmacy ph join prescription pr 
on ph.`pharmacyID` = pr.`pharmacyID`
join treatment t on t.`treatmentID` = pr.`treatmentID` 
join disease d on d.`diseaseID` = t.`diseaseID`
where year(t.date) = 2021 
GROUP BY ph.`pharmacyID`, d.`diseaseID`);


select ph.`pharmacyID` as "pharmacyId", d.`diseaseID` as "diseaseId" ,
(case
     when year(t.`date`) = 2021 then (select count(pr.`prescriptionID`) 
     from pharmacy ph join prescription pr 
     on ph.`pharmacyID` = pr.`pharmacyID`
     join treatment t on t.`treatmentID` = pr.`treatmentID` 
     join disease d on d.`diseaseID` = t.`diseaseID`
     group by ph.`pharmacyID`, d.`diseaseID` 
     order by 1 desc Limit 1)
     end 
     ) as "2021",
     (case
     when year(t.`date`) = 2022 then (select count(pr.`prescriptionID`) 
     from pharmacy ph join prescription pr 
     on ph.`pharmacyID` = pr.`pharmacyID`
     join treatment t on t.`treatmentID` = pr.`treatmentID` 
     join disease d on d.`diseaseID` = t.`diseaseID`
     group by ph.`pharmacyID`, d.`diseaseID` 
     order by 1 desc Limit 1
     )
end) as "2022"
from pharmacy ph join prescription pr 
on ph.`pharmacyID` = pr.`pharmacyID`
join treatment t on t.`treatmentID` = pr.`treatmentID` 
join disease d on d.`diseaseID` = t.`diseaseID`
where year(t.date) between 2021 and 2022

;
with cte_table as 
(select ph.`pharmacyID` as "pharmacyId", d.`diseaseID` as "diseaseId" ,
count(prescriptionId) as "cnt_prescription" 
from pharmacy ph join prescription pr 
     on ph.`pharmacyID` = pr.`pharmacyID`
     join treatment t on t.`treatmentID` = pr.`treatmentID` 
     join disease d on d.`diseaseID` = t.`diseaseID`
     group by ph.`pharmacyID`, d.`diseaseID` )
select *
from cte_table ;


-- Question 5)

select Company, State, patients_count from(
with patients_count as (
select a.state 's1', count(p.`patientID`) as "patients_cnt" 
from patient p join person pe on p.`patientID` =pe.`personID`
join address a on a.`addressID` = pe.`addressID`
group by a.state),
company_count as (
select i.`companyName` "CompanyName", a.state 's1' from 
address a join insurancecompany i on a.`addressID` = i.`addressID`
)
select s1 "State", `patients_cnt` "patients_count", `companyName` "Company"
, row_number() over(partition by s1) as n
from patients_count t1 join company_count t2 
using(s1)
order by `patients_cnt` desc) as tab
where n = 1
order by `Company`
;




WITH cte AS (
    SELECT state, `diseaseName`,COUNT(`treatmentID`) 'noOftreatments'
    FROM address
    INNER JOIN person p USING (`addressID`)
    INNER JOIN treatment t ON p.`personID`=t.`patientID`
    INNER JOIN disease USING(`diseaseID`)
    GROUP BY state,`diseaseName`
    ORDER BY state,noOftreatments DESC
)
SELECT DISTINCT state, FIRST_VALUE(`diseaseName`) OVER(PARTITION BY state) 'MinDisease',
FIRST_VALUE(noOftreatments) OVER(PARTITION BY state) 'noOfMINtreatments',
LAST_VALUE(`diseaseName`) OVER(PARTITION BY state) 'MaxDisease',
LAST_VALUE(noOftreatments) OVER(PARTITION BY state) 'noOfMAXtreatments'
FROM cte;

