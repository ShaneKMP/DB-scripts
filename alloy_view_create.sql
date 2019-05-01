
-- script to lay out how Ops needs to alloy data formatted in Redshift

------------------------------------------------------------------------------------------
-- table: rdl.alloy_evaluation_results
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_evaluation_results;

create view rdl.alloy_evaluation_results as (
  select 
    evaluation_id as alloy_evaluation_id,
    ae.submitted_at as submitted_at,
    "alloy summary_status_code" as status_code,
    "alloy summary_error" as error,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "alloy summary_application_version_id" as application_version_id,
    "alloy summary_score" as summary_score,
    "alloy summary_tags" as tags, -- note this is an array, but ok to be string here
    "alloy summary_outcome" as outcome,
    "alloy summary_average_fraud_score" as average_fraud_score,
    "alloy summary_idis_idscore_raw_score" as idis_idscore_raw_score,
    "alloy summary_socure_raw_score" as socure_raw_score,
    "alloy summary_equifax_isrb_raw_score" as equifax_isrb_raw_score
  from rdl.alloy_evaluations_flattened aef
  inner join aoa_db.alloy_evaluations ae on (ae.id = aef.evaluation_id)
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_evaluation_tags
------------------------------------------------------------------------------------------
-- Note: Not sure if my code is right, but want a new row for each element in the json array for tags

drop view if exists rdl.alloy_evaluation_tags;

create view rdl.alloy_evaluation_tags as (
  select 
    aef.evaluation_id as alloy_evaluation_id,
    aef."alloy summary_evaluation_token" as evaluation_token,
    aef."alloy summary_entity_token" as entity_token,
    aea.array_value as tags
  from rdl.alloy_evaluations_flattened aef
  inner join rdl.alloy_evaluations_array aea on aef.evaluation_id = aea.evaluation_id
                                            and aea.field_name = 'alloy summary_tags'   
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_supplied_information
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_supplied_information;

create view rdl.alloy_supplied_information as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "alloy summary_supplied_name_first" as name_first,
    "alloy summary_supplied_name_middle" as name_middle,
    "alloy summary_supplied_name_last" as name_last,
    "alloy summary_supplied_birth_date" as birth_date,
    "alloy summary_supplied_email_address" as email_address,
    "alloy summary_supplied_address_line_1" as address_line_1,
    "alloy summary_supplied_address_line_2" as address_line_2,
    "alloy summary_supplied_address_city" as address_city,
    "alloy summary_supplied_address_state" as address_state,
    "alloy summary_supplied_address_postal_code" as address_postal_code,
    "alloy summary_supplied_address_country_code" as address_country_code,
    "alloy summary_supplied_phone_number" as phone_number,
    "alloy summary_supplied_ip_address_v4" as ip_address_v4,
    "alloy summary_supplied_routing_number" as routing_number,
    "alloy summary_supplied_method_of_linking_bank_account" as method_of_linking_bank_account
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_formatted_information
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_formatted_information;

create view rdl.alloy_formatted_information as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "alloy summary_formatted_name_first" as name_first,
    "alloy summary_formatted_name_middle" as name_middle,
    "alloy summary_formatted_name_last" as name_last,
    "alloy summary_formatted_birth_date" as birth_date,
    "alloy summary_formatted_email_address" as email_address,
    "alloy summary_formatted_address_line_1" as address_line_1,
    "alloy summary_formatted_address_line_2" as address_line_2,
    "alloy summary_formatted_address_city" as address_city,
    "alloy summary_formatted_address_state" as address_state,
    "alloy summary_formatted_address_postal_code" as address_postal_code,
    "alloy summary_formatted_address_country_code" as address_country_code,
    "alloy summary_formatted_phone_number" as phone_number,
    "alloy summary_formatted_ip_address_v4" as ip_address_v4,
    "alloy summary_formatted_routing_number" as routing_number,
    "alloy summary_formatted_method_of_linking_bank_account" as method_of_linking_bank_account
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_socure_results
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_socure_results;

create view rdl.alloy_socure_results as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "socure 30_generic_fraud_score" as generic_fraud_score,
    "socure 30_name_matched" as name_matched,
    "socure 30_address_matched" as address_matched,
    "socure 30_dob_matched" as dob_matched,
    "socure 30_phone_matched" as phone_matched,
    "socure 30_ssn_matched" as ssn_matched,
    "socure 30_internationalpep" as international_pep,
    "socure 30_domesticpep" as domestic_pep,
    "socure 30_domesticofac" as domestic_ofac,
    "socure 30_address_risk_score" as address_risk_score,
    "socure 30_email_risk_score" as email_risk_score,
    "socure 30_phone_risk_score" as phone_risk_score,
    "socure 30_wachlist_matches" as wachlist_matches
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_socure_reason_codes
------------------------------------------------------------------------------------------
-- Note: Not sure if my code is right, but want a new row for each element in the json array for tags

drop view if exists rdl.alloy_socure_reason_codes;

create view rdl.alloy_socure_reason_codes as (
  select 
    f.evaluation_id as alloy_evaluation_id,
    f."alloy summary_evaluation_token" as evaluation_token,
    f."alloy summary_entity_token" as entity_token,
    aea.array_value as reason_code
  from rdl.alloy_evaluations_flattened f
  inner join rdl.alloy_evaluations_array aea on aea.evaluation_id = f.evaluation_id
                                            and aea.field_name = 'socure 30_reason_code'   
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_whitepagespro_results_phone
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_whitepagespro_results_phone;

create view rdl.alloy_whitepagespro_results_phone as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "white pages pro_phone is valid" as is_valid,
    "white pages pro_phone is connected" as is_connected,
    "white pages pro_phone name match" as phone_to_name,
    "white pages pro_phone address match" as phone_to_address,
    "white pages pro_subscriber_name" as subscriber_name,
    "white pages pro_subscriber_age_range" as subscriber_age_range,
    "white pages pro_is_subscriber_deceased" as is_subscriber_deceased,
    "white pages pro_phone is commercial" as is_commercial,
    "white pages pro_line type" as line_type,
    "white pages pro_carrier name" as carrier,
    "white pages pro_prepaid check" as is_prepaid
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_whitepagespro_results_address
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_whitepagespro_results_address;

create view rdl.alloy_whitepagespro_results_address as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "white pages pro_address is valid" as is_valid,
    "white pages pro_address is active" as is_active,
    "white pages pro_address name match" as address_to_name,
    "white pages pro_resident name" as resident_name,
    "white pages pro_resident_age_range" as resident_age_range,
    "white pages pro_is_resident_deceased" as is_resident_deceased,
    "white pages pro_address is commercial" as is_commercial,
    "white pages pro_address is forwarder" as is_forwarder,
    "white pages pro_address type" as type
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_whitepagespro_results_email
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_whitepagespro_results_email;

create view rdl.alloy_whitepagespro_results_email as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    --alloy_result -> 'raw_responses' -> 'White Pages Pro' -> 0 -> 'email_address_checks',
    "white pages pro_email is valid" as is_valid,
    "white pages pro_email diagnostics" as diagnostics,
    "white pages pro_email is auto-generated" as is_auto_generated,
    "white pages pro_email is disposable" as is_disposable,
    "white pages pro_email to name match" as email_to_name,
    "white pages pro_email registered name" as registered_name,
    "white pages pro_email registered owner age range" as registered_owner_age_range,
    "white pages pro_email first seen date" as email_first_seen_date,
    "white pages pro_email address first seen days" as email_first_seen_days,
    "white pages pro_wpp: email_address_checks.email_domain_creation_date" as email_domain_created_date,
    "white pages pro_wpp: email_address_checks.email_domain_creation_days" as email_domain_creation_days
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_whitepagespro_results_ipaddress
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_whitepagespro_results_ipaddress;

create view rdl.alloy_whitepagespro_results_ipaddress as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    --alloy_result -> 'raw_responses' -> 'White Pages Pro' ,
    "white pages pro_wpp: ip_address_checks.is_valid" as is_valid,
    "white pages pro_wpp: ip_address_checks.is_proxy" as is_proxy,
    "white pages pro_wpp: ip_address_checks.geolocation.postal_code" as geo_postal_code,
    "white pages pro_wpp: ip_address_checks.geolocation.city_name" as geo_city_name,
    "white pages pro_wpp: ip_address_checks.geolocation.subdivision" as geo_subdivision,
    "white pages pro_wpp: ip_address_checks.geolocation.country_name" as geo_country_name,
    "white pages pro_wpp: ip_address_checks.distance_from_address" as distance_from_address,
    "white pages pro_wpp: ip_address_checks.distance_from_phone" as distance_from_phone,
    "white pages pro_wpp: ip_address_checks.connection_type" as connection_type
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_idology_results
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_idology_results;

create view rdl.alloy_idology_results as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "idology expectid_summary result key" as summary_result,
    "idology expectid_result key" as results
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_iovation_results
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_iovation_results;

create view rdl.alloy_iovation_results as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "iovation_iovation realipaddress" as realipaddress,
    "iovation_iovation ipaddress" as ipaddress,
    "iovation_iovation ipaddress.isp" as ipaddress_isp,
    "iovation_iovation ipaddress.loc.city" as ipaddress_loc_city,
    "iovation_iovation ipaddress.loc.country" as ipaddress_loc_country,
    "iovation_iovation ipaddress.org" as ipaddress_org,
    "iovation_iovation realipaddress.isp" as realipaddress_isp,
    "iovation_iovation realipaddress.loc.city" as realipaddress_loc_city,
    "iovation_iovation realipaddress.loc.country" as realipaddress_loc_country,
    "iovation_iovation realipaddress.org" as realipaddress_org,
    "iovation_iovation mlvalue1" as mlvalue1
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_lexisnexis_results
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_lexisnexis_results;

create view rdl.alloy_lexisnexis_results as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    --alloy_result -> 'formatted_responses' -> 'Lexis Nexis Instant ID',
    "lexis nexis instant id_reverse phone lookup first name" as reverse_phone_first_name,
    "lexis nexis instant id_reverse phone lookup last name" as reverse_phone_last_name,
    "lexis nexis instant id_reverse phone lookup city" as reverse_phone_address_city,
    "lexis nexis instant id_reverse phone lookup state" as reverse_phone_address_state,
    "lexis nexis instant id_reverse phone lookup address postal code last5" as reverse_phone_address_postal,
    "lexis nexis instant id_phone of name and address" as reverse_phone_name_address,
    "lexis nexis instant id_is best address" as is_best_ipaddress,
    "lexis nexis instant id_is date of birth verified" as dob_verified,
    "lexis nexis instant id_is address a po box" as address_po_box,
    "lexis nexis instant id_name matched" as name_matched,
    "lexis nexis instant id_address matched" as address_matched,
    "lexis nexis instant id_ssn matched" as ssn_matched,
    "lexis nexis instant id_dob matched" as dob_matched,
    "lexis nexis instant id_phone matched" as phone_matched,
    "lexis nexis instant id_watch lists matches" as watchlists_matches,
    "lexis nexis instant id_world compliance: pep" as pep_watchlist,
    "lexis nexis instant id_world compliance: ofac" as ofac_watchlist,
    "lexis nexis instant id_identity theft risk score" as identity_theft_risk,
    "lexis nexis instant id_is address a po box" as po_box,
    "lexis nexis instant id_commercial mail receiving flag" as commercial_box,
    "lexis nexis instant id_verification: dob day" as verification_dob_day,
    "lexis nexis instant id_verification: dob month" as verification_dob_month,
    "lexis nexis instant id_verification: dob year" as verification_dob_year,
    "lexis nexis instant id_verification: full name" as verification_name_first_last,
    "lexis nexis instant id_verification: last name + address" as verification_name_last_address,
    "lexis nexis instant id_verification: last name + phone" as verification_name_last_phone,
    "lexis nexis instant id_verification: first name + ssn" as verification_name_first_ssn,
    "lexis nexis instant id_verification: last name + ssn" as verification_name_last_ssn,
    "lexis nexis instant id_verification: last name + addresss + ssn" as verification_name_address_ssn
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_equifax_results
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_equifax_results;

create view rdl.alloy_equifax_results as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "equifax xml_isrb_score" as isrb_score,
    "equifax xml_fico_score" as fico_score,
    "equifax xml_unavailable" as data_unavailable,
    "equifax xml_fraud_victim_indicator" as fraud_victim_indicator
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_idanalytics_results
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_idanalytics_results;

create view rdl.alloy_idanalytics_results as (
  select 
    evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    "id analytics id network attributes_name matched" as name_matched,
    "id analytics id network attributes_address matched" as address_matched,
    "id analytics id network attributes_ssn matched" as ssn_matched,
    "id analytics id network attributes_dob matched" as dob_matched
  from rdl.alloy_evaluations_flattened
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_idanalytics_reason_codes 
------------------------------------------------------------------------------------------
-- Note: Not sure if my code is right, but want a new row for each element in the json array for tags

drop view if exists rdl.alloy_idanalytics_reason_codes;

create view rdl.alloy_idanalytics_reason_codes as (
  select 
    f.evaluation_id as alloy_evaluation_id,
    "alloy summary_evaluation_token" as evaluation_token,
    "alloy summary_entity_token" as entity_token,
    aea.array_value as reason_code
  from rdl.alloy_evaluations_flattened f
  inner join rdl.alloy_evaluations_array aea on aea.evaluation_id = f.evaluation_id
                                            and aea.field_name = 'id analytics id network attributes_reason codes'   
);


------------------------------------------------------------------------------------------
-- table: rdl.alloy_manual_review
------------------------------------------------------------------------------------------

drop view if exists rdl.alloy_manual_review;

create view rdl.alloy_manual_review as (
  select 
    evaluation_review_id as alloy_review_id,
    er.alloy_evaluation_id as alloy_evaluation_id,
    review_token as review_token,
    outcome as review_outcome,
    reason as review_reason,
    reviewer as reviewer,
    timestamp as review_timestamp,
    er.created_at as created_at,
    er.updated_at as updated_at
  from rdl.alloy_evaluation_reviews_flattened aerf
  inner join aoa_db.evaluation_reviews er on (er.id = aerf.evaluation_review_id)
);
