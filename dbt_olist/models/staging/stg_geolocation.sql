with source as (
    select * from {{ source('olist_raw', 'geolocation') }}
),

renamed as (
    select
        GEOLOCATION_ZIP_CODE_PREFIX                         as zip_code,
        GEOLOCATION_LAT::float                              as latitude,
        GEOLOCATION_LNG::float                              as longitude,
        lower(trim(GEOLOCATION_CITY))                       as city,
        upper(trim(GEOLOCATION_STATE))                      as state
    from source
)

select * from renamed