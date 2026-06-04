with source as (
    select * from {{ source('olist_raw', 'sellers') }}
),

renamed as (
    select
        SELLER_ID                                           as seller_id,
        SELLER_ZIP_CODE_PREFIX                              as seller_zip_code,
        lower(trim(SELLER_CITY))                            as seller_city,
        upper(trim(SELLER_STATE))                           as seller_state
    from source
)

select * from renamed