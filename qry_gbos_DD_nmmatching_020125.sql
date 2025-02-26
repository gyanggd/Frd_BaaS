DROP TABLE IF EXISTS #dd_gbos;
CREATE TABLE #dd_gbos as
SELECT
-- achB.ACHCategoryKey
count(distinct achT.AccountIdentifier) as cnt_AIs
, count(achT.achtransactionidentifier) as cnt_ACHtrans
, sum(achT.transamount) as sum_ACHamt
/*
top 20000 achT.AccountIdentifier,
       acht.achbatchkey,
       achT.achtransactionidentifier,
       achB.ACHCategoryKey,
       --achF.ACHFileCreationDate,
       achF.createdate,
       pdr_stg.decryptaes(achT.customername) AS achcustomername,
       pdr_stg.decryptaes(achT.lastname) AS achlastname,
       pdr_stg.decryptaes(cf.firstname) AS firstname,
       pdr_stg.decryptaes(cf.middlename) AS middlename,
       pdr_stg.decryptaes(cf.lastname) AS lastname,
       achT.transamount
*/
FROM gbos_directdeposit.achtransaction achT
  INNER JOIN gbos_directdeposit.ACHBatch achB ON achT.ACHBatchKey = achB.ACHBatchKey
  INNER JOIN gbos_directdeposit.ACHFileHeader achF ON achB.ACHFileHeaderKey = achF.ACHFileHeaderKey
  INNER JOIN gbos.account ac
          ON achT.AccountIdentifier = ac.AccountIdentifier
         AND ac.sor_uid = 24
  INNER JOIN gbos.accountholder ah
          ON ah.accountkey = ac.accountkey
         AND ah.sor_uid = ac.sor_uid
  INNER JOIN gbos.consumerprofile cf
          ON cf.consumerprofilekey = ah.consumerprofilekey
         AND ah.sor_uid = cf.sor_uid
WHERE 1 = 1
--achT.AccountIdentifier = @AccountIdentifier
AND   achT.achtransactionstatuskey = 3
-- successful
AND   achB.ACHCategoryKey IN (4,5,7,11,12,13,8)
--4: government benifits 5: child support 7: Payroll 11: other pay 12: unemployment 13: penson 8: Unknown
AND   CAST(achF.ACHFileCreationDate AS DATE) >= '01/01/2024'
AND   CAST(achF.ACHFileCreationDate AS DATE) <= '12/31/2024'
AND   programcode = 'gbr'
group by 1
--gbos
ORDER BY RANDOM();

/*
SELECT ACHCategoryKey
, count(distinct AccountIdentifier) as cnt_AIs
, count(achtransactionidentifier) as cnt_ACHtrans
, sum(transamount) as sum_ACHamt
from #dd_gbos
group by 1
;
*/

select * from #dd_gbos;

--select top 100 * from gbos_directdeposit.ACHCategory
--;



