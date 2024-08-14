{{ config(materialized='view') }}


with raw_pdf_data as (
    select * 
    from raw_pdf 
    order by substr(file_name,charindex('_',file_name)+1,charindex('.',file_name)-(charindex('_',file_name)+1))::date
    )
select 
raw_pdf_seq.nextval as row_id,
file_name,
file_timestamp,
pdf_json_values from raw_pdf_data