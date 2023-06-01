--1A:
--Which prescribber had highest total number of claims (totaled over all drugs)? 
--Report NPI & total number of claims
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC; 

--1B:
--Which provider had highest number of claims (totaled over all drugs)? 
--List first, last name, specialty, and total number of claims. 
SELECT prescriber.npi, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims
FROM prescription LEFT JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description
ORDER BY total_claims DESC;


--2A:
--Which specialty had the number of claims?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claim_per_specialty
FROM prescription LEFT JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY specialty_description
ORDER BY total_claim_per_specialty DESC; 

--2B:
--Specialty with the most claims for opioids?
SELECT prescriber.specialty_description, COUNT(drug.opioid_drug_flag) AS specialty_opioid_prescriptions
FROM prescription LEFT JOIN prescriber ON prescriber.npi = prescription.npi
				  LEFT JOIN drug ON drug.drug_name = prescription.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY specialty_opioid_prescriptions DESC;


--2C:
--2D:

--3A:
--Generic drug with the highest total cost? 
SELECT drug.generic_name, SUM(prescription.total_drug_cost) AS generic_name_total_cost
FROM prescription LEFT JOIN drug ON drug.drug_name = prescription.drug_name
GROUP BY generic_name 
ORDER BY generic_name_total_cost DESC; 


--3B:
--Which generic drug has the highest total cost per day? 
--BONUS: ROUND cost per day column to 2 decimal places. 
SELECT drug.generic_name, ROUND(SUM(prescription.total_drug_cost)/365, 2) AS generic_name_total_cost
FROM prescription LEFT JOIN drug ON drug.drug_name = prescription.drug_name
GROUP BY generic_name 
ORDER BY generic_name_total_cost DESC; 

--4A:
SELECT drug_name,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic'
		ELSE 'Neither' END AS drug_type
FROM drug 
ORDER BY drug_name;

--4B:
SELECT drug_name,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antibiotic' END AS drug_type
FROM drug 
ORDER BY drug.drug_name;

--NEED HELP GETTING RID OF THE 'NEITHER' UNDER DRUG_TYPE COLUMN.. SEE NOTES ABOVE



--5A:
--How many CBSA's are in TN? 
--Below there are a few with TN as well as other states..Do these count towards being included OR are we specicalty looking for strictly CBSA's operating ONLY in TN? 
SELECT *
FROM cbsa
WHERE cbsaname LIKE '%TN%'
--COUNTED TOTAL FOR ABOVE:
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

--5B:
--Which CBSA has the largest combined population?
--Which has the smallest combined population?
--REPORT THE NAME & TOTAL POPULATION FOR BOTH... 
--LARGEST:
--34980--NASHVILLE-DAVIDSON-MURFREESBORO-FRANKLIN,TN-- 1,830,410
--SMALLEST:
--34100--MORRISTOWN,TN --116,352

SELECT cbsa,cbsaname, SUM(population) AS cbsa_population
FROM cbsa FULL JOIN population ON cbsa.fipscounty = population.fipscounty
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsa, cbsaname
ORDER BY cbsa_population DESC;

SELECT cbsa,cbsaname, SUM(population) AS cbsa_population
FROM cbsa FULL JOIN population ON cbsa.fipscounty = population.fipscounty
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsa, cbsaname
ORDER BY cbsa_population;


--5C:
--WHAT IS THE LARGEST (IN TERM OF POPULATION) COUNTY WHICH IS NOT INCLUDED IN THE CBSA? 
--REPORT COUNTY NAME & POPULATION..
--SMALLEST:
--PICKETT,TN--5071
--LARGEST:
--SEVIER,TN--95,523
SELECT fips_county.county, fips_county.state, population.population AS no_cbsa_population
FROM fips_county FULL JOIN population ON fips_county.fipscounty = population.fipscounty
				 FULL JOIN cbsa ON fips_county.fipscounty = cbsa.fipscounty
WHERE cbsa IS NULL AND population IS NOT NULL
GROUP BY fips_county.county, fips_county.state, population.population
ORDER BY no_cbsa_population DESC;


--6A:
--Find drugs & total claims with over 3,000 claims. 
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count > 3000
GROUP BY drug_name, total_claim_count
ORDER BY total_claim_count DESC;

--6B:
--Which of the above are Opioids or other drugs
SELECT prescription.drug_name, prescription.total_claim_count,
		CASE WHEN drug.opioid_drug_flag = 'Y' THEN 'Opioid'
		ELSE 'Other' END AS drug_type
FROM prescription left JOIN drug ON prescription.drug_name = drug.drug_name
WHERE total_claim_count > 3000
GROUP BY prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag
ORDER BY total_claim_count DESC;

--6C:
--Add column with prescriber first and last name assoicated with each. 
SELECT prescriber.nppes_provider_last_org_name, prescriber.nppes_provider_first_name, prescription.drug_name, SUM(prescription.total_claim_count) AS total_claims,
		CASE WHEN drug.opioid_drug_flag = 'Y' THEN 'Opioid'
		ELSE 'Other' END AS drug_type
FROM prescription LEFT JOIN drug ON prescription.drug_name = drug.drug_name
				  LEFT JOIN prescriber ON prescriber.npi = prescription.npi
WHERE total_claim_count > 3000
GROUP BY prescription.drug_name, drug.opioid_drug_flag, prescriber.nppes_provider_last_org_name, prescriber.nppes_provider_first_name
ORDER BY total_claims DESC;

--Is this correct or are there multiple providers per claim?..

--7A:
SELECT prescription.npi, prescription.drug_name, prescriber.specialty_description, prescriber.nppes_provider_city, drug.opioid_drug_flag
FROM prescription FULL JOIN drug ON drug.drug_name = prescription.drug_name
				  FULL JOIN prescriber ON prescriber.npi = prescription.npi
WHERE prescriber.specialty_description = 'Pain Management' 
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
GROUP BY prescription.npi, prescription.drug_name, prescriber.specialty_description, prescriber.nppes_provider_city, drug.opioid_drug_flag;

--7B:
SELECT npi, drug_name, total_claim_count
FROM prescription
ORDER BY total_claim_count


--7C:


----------------------------------------------------BONUS QUESTIONS:-------------------------------------------------------------------
--1:

--2A:
--TOP 5 generic name for Family Practice specialty:
SELECT drug.generic_name, SUM(prescription.total_claim_count) AS claims_per_drug, prescriber.specialty_description
FROM drug FULL JOIN prescription ON prescription.drug_name = drug.drug_name
		  LEFT JOIN prescriber ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_count IS NOT NULL 
		AND prescriber.specialty_description = 'Family Practice' 
GROUP BY drug.generic_name, prescriber.specialty_description
ORDER BY claims_per_drug DESC
LIMIT 5; 

--2B:
--TOP 5 generic name for Cardiology specialty:
SELECT drug.generic_name, SUM(prescription.total_claim_count) AS claims_per_drug, prescriber.specialty_description
FROM drug FULL JOIN prescription ON prescription.drug_name = drug.drug_name
		  LEFT JOIN prescriber ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_count IS NOT NULL 
		AND prescriber.specialty_description = 'Cardiology' 
GROUP BY drug.generic_name, prescriber.specialty_description
ORDER BY claims_per_drug DESC
LIMIT 5; 

--2C:
--TOP 5 for both combined specialties:
SELECT drug.generic_name, SUM(prescription.total_claim_count) AS claims_per_drug, prescriber.specialty_description
FROM drug FULL JOIN prescription ON prescription.drug_name = drug.drug_name
		  LEFT JOIN prescriber ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_count IS NOT NULL 
		AND prescriber.specialty_description = 'Cardiology' OR prescriber.specialty_description = 'Family Practice'
GROUP BY drug.generic_name, prescriber.specialty_description
ORDER BY claims_per_drug DESC
LIMIT 5;

--3A:
----Top total claims prescribers in Nashville:
SELECT prescriber.npi, SUM(prescription.total_claim_count) AS total_claims, prescriber.nppes_provider_city
FROM prescription FULL JOIN prescriber ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_count IS NOT NULL
	AND prescriber.nppes_provider_city = 'NASHVILLE'
GROUP BY prescriber.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5;

--3B:
----Top total claims prescribers in Memphis:
SELECT prescriber.npi, SUM(prescription.total_claim_count) AS total_claims, prescriber.nppes_provider_city
FROM prescription FULL JOIN prescriber ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_count IS NOT NULL
	AND prescriber.nppes_provider_city = 'MEMPHIS'
GROUP BY prescriber.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5;

--3C:
----Top total claims prescribers across all 4 major metro hubs in TN. 
SELECT prescriber.npi, SUM(prescription.total_claim_count) AS total_claims, prescriber.nppes_provider_city
FROM prescription LEFT JOIN prescriber ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_count IS NOT NULL
		AND prescriber.nppes_provider_city = 'NASHVILLE' OR prescriber.nppes_provider_city = 'MEMPHIS' 
		OR prescriber.nppes_provider_city = 'KNOXVILLE' OR prescriber.nppes_provider_city = 'CHATANOOGA'
GROUP BY prescriber.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC;


--4:
----Find all counties which had above-avg number of overdose deathes
--Report county name & number of overdose deathes
SELECT *
FROM overdose_deaths LEFT JOIN fips_county USING(fipscounty)
SELECT *
FROM fips_county LEFT JOIN overdose_deaths ON fips_county.fipscounty = overdose_deaths.fipscounty

--5A:
--TN TOTAL POPULATION
SELECT SUM(population) AS tn_total_pop
FROM population; 

--5B:
SELECT *
FROM population

SELECT fips_county.county, pop1.population, SUM(pop2.population) AS percentage_of_total_tn_pop
FROM population AS pop1 INNER JOIN population AS pop2 USING(fipscounty)
						LEFT JOIN fips_county ON fips_county.fipscounty = pop1.fipscounty
GROUP BY fips_county.county, pop1.population












