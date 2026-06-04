with source as (
    select * from {{ source('olist_raw', 'products') }}
),

renamed as (
    select
        PRODUCT_ID                                          as product_id,
        PRODUCT_CATEGORY_NAME                               as product_category_name_pt,
        PRODUCT_NAME_LENGHT::int                            as product_name_length,
        PRODUCT_DESCRIPTION_LENGHT::int                     as product_description_length,
        PRODUCT_PHOTOS_QTY::int                             as product_photos_qty,
        PRODUCT_WEIGHT_G::float                             as product_weight_g,
        PRODUCT_LENGTH_CM::float                            as product_length_cm,
        PRODUCT_HEIGHT_CM::float                            as product_height_cm,
        PRODUCT_WIDTH_CM::float                             as product_width_cm
    from source
)

select * from renamed