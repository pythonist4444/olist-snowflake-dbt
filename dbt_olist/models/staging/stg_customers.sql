with source as (
    select * from {{ source('olist_raw', 'customers') }}
),

renamed as (
    select
        CUSTOMER_ID                                         as customer_id,
        CUSTOMER_UNIQUE_ID                                  as customer_unique_id,
        CUSTOMER_ZIP_CODE_PREFIX                            as customer_zip_code,
        lower(trim(CUSTOMER_CITY))                          as customer_city,
        upper(trim(CUSTOMER_STATE))                         as customer_state
    from source
)

select * from renamed