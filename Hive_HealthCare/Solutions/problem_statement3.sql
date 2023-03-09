-- Active: 1671690241285@@127.0.0.1@3308@healthcare

-- Question 1:
select ph.`pharmacyID`, count(m.`hospitalExclusive`) "Number of times pharmacy prescribed exclusive medicines" from treatment t join prescription p on t.`treatmentID` = p.`treatmentID` 
join pharmacy ph on ph.`pharmacyID` = p.`pharmacyID` join `keep` k on ph.`pharmacyID` = k.`pharmacyID` 
join medicine m on m.`medicineID` = k.`medicineID`
where m.`hospitalExclusive` = 'S' and year(t.date) between 2021 and 2022
group by ph.`pharmacyID`
order by 2 desc;

-- Question 2:

select ic.`companyName`, ip.`planName`, count(t.`treatmentID`) as "The number of treatments" from insuranceCompany ic 
join insuranceplan ip on ic.`companyID` = ip.`companyID`
join claim c on c.uin = ip.uin join treatment t on t.`claimID` = c.`claimID`
group by ic.`companyName`, ip.`planName`;

-- Question 3:
with cte_table as (
select ic.`companyName`, ip.`planName`, count(t.`treatmentID`) as "No. treatments" from insuranceCompany ic 
join insuranceplan ip on ic.`companyID` = ip.`companyID`
join claim c on c.uin = ip.uin join treatment t on t.`claimID` = c.`claimID`
group by ic.`companyName`, ip.`planName`)
select companyName, 
Max(CASE WHEN `No. treatments` = (select max(`No. treatments`) from cte_table c2 where c1.`companyName` = c2.`companyName` ) THEN c1.`planName` END) AS 'Most claimed plans',
Max(CASE WHEN `No. treatments` = (select min(`No. treatments`) from cte_table c2 where c1.`companyName` = c2.`companyName` ) THEN c1.`planName` END) AS 'Least claimed plans' from cte_table c1
group by `companyName`
order by `companyName`;


-- with cte AS (SELECT `companyName`,`planName`, COUNT(`claimID`) 'claimCount'
-- FROM insurancecompany
-- INNER JOIN insuranceplan USING (`companyID`)
-- LEFT JOIN claim USING(uin)
-- GROUP BY `companyName`,`planName`
-- ORDER BY `companyName`,claimCount DESC
-- )
-- SELECT DISTINCT`companyName`, 
-- FIRST_VALUE(`planName`) OVER(PARTITION BY `companyName`) 'MaxClaim',
-- LAST_VALUE(`planName`) OVER(PARTITION BY `companyName`) 'MinClaim'
-- FROM cte
-- ORDER BY `companyName`;

--Question 4:

with person_address as(
select sum(p.`personID`) as "Person", a.state as "State" from address a 
join person p on a.`addressID` = p.`addressID`
group by a.state),

patient_address as(
    select sum(p.`patientID`) as "Patient", a.state as "State" from patient p join treatment t on p.`patientID` = t.`patientID`
    join prescription pr on pr.`treatmentID` = t.`treatmentID`
    join pharmacy ph on ph.`pharmacyID` = pr.`pharmacyID`
    join address a on a.`addressID` = ph.`addressID`
    group by a.state)

select *,  pa.person / pta.patient as "ratio" from person_address pa 
join patient_address pta using(`State`)
order by 4 desc;

-- Question 5:

select  ph.`pharmacyID`, sum(k.quantity) as "Total Quantity" from  medicine m  join keep k on k.`medicineID` = m.`medicineID` 
                           join  pharmacy ph on ph.`pharmacyID` = k.`pharmacyID`
                           join address a on a.`addressID` = ph.`addressID`
                           join prescription pr on pr.`pharmacyID` = ph.`pharmacyID`
                           join treatment t on t.`treatmentID` = pr.`treatmentID`
where a.state = "AZ" and m.`taxCriteria` = "I" and year(t.`date`) = 2021
group by  ph.`pharmacyID`;