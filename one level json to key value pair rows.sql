create temp table t as 
with tmp as (
    select id as user_id,
          user_fields
    from prod_zendesk.zendesk_users
    where user_fields is not null 
    limit 1)  
                                                                                                                                                                                                                                                                                                                                 
    , tmp1 as (
      select user_id,
          replace(replace(replace(user_fields, '{', ''), '}', ''), '"', '') as user_fields
      from tmp)
    
    , numbers as (
      select 1 as n union all
      select 2 union all
      select 3 union all
      select 4 union all
      select 5 union all
      select 6 union all
      select 7 union all
      select 8 union all
      select 9 union all
      select 10 
      )     
    
    , tmp2  as (
  select tmp1.user_id
    ,trim(split_part(split_part(user_fields, ',', n), ': ', 1)) as k
    ,trim(split_part(split_part(user_fields, ',', n), ': ', 2)) as v
  from tmp1
    cross join numbers
  where split_part(user_fields, ',', n) is not null
    and split_part(user_fields, ',' ,n) != '')

select * from tmp2;    
    
select * from t
