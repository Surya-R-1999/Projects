-- Active: 1671690241285@@127.0.0.1@3308@healthcare

-- Question 1:
select a.state, COALESCE(pe.gender, "Total_Count") as "Gender" ,count(t.`treatmentID`) as "treatment_cnt"
from `disease` d join `treatment` t on d.`diseaseID` =  t.`diseaseID`
               join `prescription` pr on pr.`treatmentID` = t.`treatmentID`
               join `pharmacy` ph on ph.`pharmacyID` = pr.`pharmacyID`
               join `address` a on a.`addressID` = ph.`addressID`
               join `person` pe on pe.`addressID` = a.`addressID`
where d.`diseaseName` = "Autism"
group by a.state, pe.gender with ROLLUP;

-- Question 2:

with cte_table as(
select  ip.`planName` as "planName", ic.`companyName` as "CompanyName", c.`claimID` as "Claims", year(t.date) as "Year"
from insurancecompany ic join insuranceplan ip on ic.`companyID` = ip.`companyID`
                         join claim c on c.uin = ip.uin
                         join treatment t on t.`claimID` = c.`claimID`
where year(t.date) in (2020, 2021, 2022))
select  CompanyName, COALESCE(`planName`,"Total_cnt of claims") as planName, COALESCE(Year, "Total_cnt_yrs") as "Year" ,count(Claims) as "claims_cnt" 
from cte_table
group by  `CompanyName`,`planName`, Year with rollup
having count(Claims) < 5000
order by 1
;

-- Question 3:
with cte_table as(
select a.state as 'state', d.`diseaseName` as "Disease", 
count(t.`treatmentID`) as "treatment_cnt"
from `disease` d join `treatment` t on d.`diseaseID` =  t.`diseaseID`
               join `prescription` pr on pr.`treatmentID` = t.`treatmentID`
               join `pharmacy` ph on ph.`pharmacyID` = pr.`pharmacyID`
               join `address` a on a.`addressID` = ph.`addressID`
               join `person` pe on pe.`addressID` = a.`addressID`
where year(t.date) = 2022
group by a.state, d.`diseaseID`)
select `state`, 
max(CASE WHEN `treatment_cnt` in (select max(`treatment_cnt`) from cte_table c2 where c1.Disease = c2.Disease ) Then c1.`Disease` END) AS 'MOST TREATED DISEASE',
max(CASE WHEN `treatment_cnt` in (select min(`treatment_cnt`) from cte_table c2 where c1.Disease = c2.Disease) Then c1.`Disease` END) AS 'LEAST TREATED DISEASE'
from cte_table c1
GROUP BY `state`;

select tab.state, tab.disease, d.`diseaseName`,  tab.treatment_cnt from(
select a.state as 'state', d.`diseaseID` as "disease", count(t.`treatmentID`) as "treatment_cnt"
from `disease` d join `treatment` t on d.`diseaseID` =  t.`diseaseID`
               join `prescription` pr on pr.`treatmentID` = t.`treatmentID`
               join `pharmacy` ph on ph.`pharmacyID` = pr.`pharmacyID`
               join `address` a on a.`addressID` = ph.`addressID`
               join `person` pe on pe.`addressID` = a.`addressID`
where year(t.date) = 2022 and a.state = "TN"
group by a.state, d.`diseaseID`) as tab
join disease d on d.`diseaseID` = tab.disease;

-- Question 4:

select ph.`pharmacyName`, d.`diseaseID`, count(pr.`prescriptionID`) as "prescription_cnt" from pharmacy ph 
                          left join prescription pr on ph.`pharmacyID` = pr.`pharmacyID`
                          right join treatment t on t.`treatmentID` = pr.`treatmentID`
                          right join disease d on d.`diseaseID` = t.`diseaseID`
where year(t.`date`) = 2022
group by ph.`pharmacyName`, d.`diseaseID` with ROLLUP;


-- Question 5:

select d.`diseaseID`, COALESCE(pe.gender,"Count") as Gender ,count(t.`treatmentID`) as "treatment_cnt"
from disease d join treatment t on d.`diseaseID` = t.`diseaseID`
join patient p on p.`patientID` = t.`patientID`
join person pe on pe.`personID` = p.`patientID`
where year(t.date) = 2022
group by d.`diseaseID`, pe.gender with rollup;


