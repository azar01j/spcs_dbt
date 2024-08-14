{{
    config(
        materialized='incremental',
        on_schema_change='fail',
        unqiue_key='file_timestamp'
        )
}}

with cte as (
SELECT 
p.key||'_'||p.seq as key_seq,q.value['value']::varchar(50) as val_i, p.path as pth_,FILE_NAME,file_timestamp,
substr(file_name,charindex('_',file_name)+1,charindex('.',file_name)-(charindex('_',file_name)+1))::date as fl_Date
FROM {{ 'raw_pdf_data' }},
LATERAL FLATTEN(input => PDF_JSON_VALUES) p,
LATERAL FLATTEN(input => p.value) q
),
cte2 as (
select distinct file_name,fl_date,file_timestamp,pth_, listagg(val_i,' , ') within group (order by 1) over (PARTITION by key_seq ) as agg_ from cte
)
select * from cte2 
where pth_<>'__documentMetadata'


{% if is_incremental() %}
      AND  file_timestamp > (select max(file_timestamp) from {{ this }})
{% endif %}