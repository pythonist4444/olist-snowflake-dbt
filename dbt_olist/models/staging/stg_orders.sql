with source as (
    select * from {{ source('olist_raw', 'orders') }}
),

renamed as (
    select 
        ORDER_ID                                            as order_id,
        CUSTOMER_ID                                         as customer_id,
        ORDER_STATUS                                        as order_status,
        try_to_timestamp(ORDER_PURCHASE_TIMESTAMP)          as order_purchased_at,
        try_to_timestamp(ORDER_APPROVED_AT)                 as order_approved_at,
        try_to_timestamp(ORDER_DELIVERED_CARRIER_DATE)      as order_delivered_carrier_at,
        try_to_timestamp(ORDER_DELIVERED_CUSTOMER_DATE)     as order_delivered_customer_at,
        try_to_timestamp(ORDER_ESTIMATED_DELIVERY_DATE)     as order_estimated_delivery_at
    from source
)

select * from renamed 