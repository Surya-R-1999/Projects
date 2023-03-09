-- Active: 1671690241285@@127.0.0.1@3308@healthcare

-- Question 1:

delimiter #
CREATE PROCEDURE if not exists sp1(IN d_id int)
BEGIN
    select * from(
    with cte_table as(
    select d.`diseaseID` as "diseaseId", count(c.`claimID`) as "claims_cnt"
    from disease d join treatment t on d.`diseaseID` = t.`diseaseID`
    join claim c on c.`claimID` =  t.`claimID`
    group by d.`diseaseID`)
    select `diseaseID`, `claims_cnt`, if(`claims_cnt` > avg(`claims_cnt`), 
    "claimed higher than average", "claimed lower than average") as "desc" from cte_table
    group by `diseaseId`) as tab
    where d_id = diseaseId;
END #
delimiter ;
call sp1(29) ;


-- Question 2:

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS SP2(IN D_ID INT)
BEGIN
    select Disease, `number_of_male_treated`,`number_of_female_treated`,
    if(`number_of_male_treated` > `number_of_female_treated`,"male","female") as "more_treated_gender"
    from(
    with cte_table as (
    select d.`diseaseName` as "Disease", pe.gender as "Gender", 
    count(t.`treatmentID`) as "treatment_cnt"
    from disease d join treatment t on d.`diseaseID` = t.`diseaseID`
    join patient p on p.`patientID` = t.`patientID`
    join person pe on pe.`personID` = p.`patientID`
    group by d.`diseaseName`, pe.gender with rollup)
    select Disease as "Disease",
    sum(case when Gender = "male" then treatment_cnt end) as "number_of_male_treated",
    sum(case when Gender = "female" then treatment_cnt end) as "number_of_female_treated"
    from cte_table
    group by Disease) as tab join disease d on d.`diseaseName` = tab.Disease
    where D_ID = d.`diseaseID`;
END $$

DELIMITER ;

CALL SP2(14);

-- Question 3:
WITH cte AS (
    SELECT `companyName`,`planName`,COUNT(`claimID`) AS noOfClaims,
    DENSE_RANK() OVER(ORDER BY COUNT(`claimID`) DESC) AS 'dRank'
    FROM insuranceplan
    INNER JOIN claim USING(uin)
    INNER JOIN insurancecompany USING(`companyID`)
    GROUP BY `companyName`,`planName`
)
(SELECT `companyName`,`planName`, 'Least Claimed' FROM cte ORDER BY dRank DESC LIMIT 3) 
UNION
SELECT `companyName`,`planName`,'Most Claimed' FROM cte
WHERE dRank<4;



-- Question 4:
with cte as
(select d.diseaseName,
case
	when pat.dob>='2005-01-01' and per.gender='male' then 'YoungMale'
    when pat.dob>='2005-01-01' and per.gender='female' then 'YoungFemale'
    when pat.dob<'2005-01-01' and pat.dob>='1985-01-01' and per.gender='male' then 'AdultMale'
    when pat.dob<'2005-01-01' and pat.dob>='1985-01-01' and per.gender='female' then 'AdultFemale'
	when pat.dob<'1985-01-01' and pat.dob>='1970-01-01' and per.gender='male' then 'MidAgeMale'
    when pat.dob<'1985-01-01' and pat.dob>='1970-01-01' and per.gender='female' then 'MidAgeFemale'
    when pat.dob<'1970-01-01' and per.gender='male' then 'ElderMale'
    when pat.dob<'1970-01-01' and per.gender='female' then 'ElderFemale'
end as category
from patient pat join person per on pat.patientID=per.personID
join treatment t on t.patientID=pat.patientID
join disease d on t.diseaseID=d.diseaseID),

cte2 as 
(select diseaseName,category,count(category) as counts
from cte
group by diseaseName,category
order by diseaseName, counts)

select diseaseName,category
from cte2 a
where counts=(select max(counts) from cte2 b where a.diseaseName=b.diseaseName);


-- Question 5:
with cte_table as (
select m.`companyName` "Company", m.`productName` "Product", 
m.description, m.`maxPrice`,
(case when `maxPrice` < 5 then "Affordable" 
      when  `maxPrice` > 1000 then "Pricy"
end)  as "category"
from medicine m
order by m.`maxPrice`)
select `Company`, `Product`, `category` from cte_table
where `category` in ("Pricy", "Affordable");
