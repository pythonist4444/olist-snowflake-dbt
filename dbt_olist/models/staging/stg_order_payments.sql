with source as (
    select * from {{ source('olist_raw', 'order_payments') }}
),

renamed as (
    select
        ORDER_ID                                            as order_id,
        PAYMENT_SEQUENTIAL::int                             as payment_sequential,
        PAYMENT_TYPE                                        as payment_type,
        PAYMENT_INSTALLMENTS::int                           as payment_installments,
        PAYMENT_VALUE::float                                as payment_value
    from source
)

select * from renamed