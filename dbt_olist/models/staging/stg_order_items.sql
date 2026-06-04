with source as (
    select * from {{ source('olist_raw', 'order_items') }}
),

renamed as (
    select
        ORDER_ID                                            as order_id,
        ORDER_ITEM_ID::int                                  as order_item_id,
        PRODUCT_ID                                          as product_id,
        SELLER_ID                                           as seller_id,
        try_to_timestamp(SHIPPING_LIMIT_DATE)               as shipping_limit_at,
        PRICE::float                                        as price,
        FREIGHT_VALUE::float                                as freight_value
    from source
)

select * from renamed