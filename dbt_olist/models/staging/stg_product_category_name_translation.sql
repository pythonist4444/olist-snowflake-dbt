with source as (
    select * from {{ source('olist_raw', 'product_category_name_translation') }}
),

renamed as (
    select
        PRODUCT_CATEGORY_NAME                               as product_category_name_pt,
        PRODUCT_CATEGORY_NAME_ENGLISH                       as product_category_name_en
    from source
)

select * from renamed