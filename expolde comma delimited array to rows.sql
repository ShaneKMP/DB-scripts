CREATE TEMPORARY TABLE tmp AS(
SELECT evaluation_id,
  field_name,
  extracted
  FROM rdl.alloy_evaluations_parsed
  --where evaluation_id = 18 --and extracted = '["32","10","RS","90"]'
  where extracted LIKE '[%]' and extracted != '[]'
  );       
                                                                                                                                                                                                                                                                                                                                 
select * from tmp; 
                                                                                                                                                                                      
update tmp
set extracted = replace(replace(replace(extracted, '"', ''), '[', ''), ']', '');                                                                                                                 
                                                                                                                                                                                
create temporary table numbers as (
select 1 as n union all
select 2 union all
select 3 union all
select 4 union all
select 5 union all
select 6 union all
select 7 union all
select 8 union all

select 9 union all
select 10 union all
select 11 union all
select 12 union all
select 13 union all
select 14 union all
select 15 union all
select 16 union all
select 17 union all
select 18 
union all
select 19 union all
select 20 union all
select 21 union all
select 22 union all
select 23 union all
select 24 union all
select 25)  ;                                                   
     
select * from numbers;
                                                                                                                                                                             
select tmp.*
  ,split_part(extracted, ',', n)
from tmp
  cross join numbers
where split_part(extracted, ',', n) is not null
  and split_part(extracted, ',' ,n) != '' ;  