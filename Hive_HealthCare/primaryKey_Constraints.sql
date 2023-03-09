Alter table `address` add constraint `PK_address` PRIMARY key(`addressId`); 
Alter table `disease` add constraint `PK_disease` PRIMARY key(`diseaseId`); 
Alter table `InsuranceCompany` add constraint `PK_InsuranceCompany` PRIMARY key(`companyId`); 
Alter table `InsurancePlan` add constraint `PK_InsurancePlan` PRIMARY key(`UIN`); 
Alter table `claim` add constraint `PK_claim` PRIMARY key(`claimId`); 
Alter table `contain` add constraint `PK_contain` PRIMARY key(`prescriptionID`,`medicineID`); 
Alter table `keep` add constraint `PK_keep_` PRIMARY key(`medicineID`); 
Alter table `medicine` add constraint `PK_medicine` PRIMARY key(`medicineID`); 
Alter table `patient` add constraint `PK_patient` PRIMARY key(`patientID`); 
Alter table `person` add constraint `PK_person` PRIMARY key(`personID`); 
Alter table `pharmacy` add constraint `PK_pharmacy` PRIMARY key(`pharmacyID`); 
Alter table `prescription` add constraint `PK_prescription` PRIMARY key(`prescriptionID`); 
Alter table `treatment` add constraint `PK_treatment` PRIMARY key(`treatmentID`); 

