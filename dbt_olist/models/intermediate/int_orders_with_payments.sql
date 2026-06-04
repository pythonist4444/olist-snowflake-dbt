with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select
        order_id,
        sum(payment_value)                              as total_payment_value,
        max(payment_installments)                       as max_payment_installments,
        count(distinct payment_type)                    as payment_type_count,
        listagg(distinct payment_type, ', ')
            within group (order by payment_type)        as payment_types_used
    from {{ ref('stg_order_payments') }}
    group by order_id
),

reviews as (
    select
        order_id,
        max(review_score)                               as review_score
    from {{ ref('stg_order_reviews') }}
    group by order_id
),

joined as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchased_at,
        o.order_approved_at,
        o.order_delivered_carrier_at,
        o.order_delivered_customer_at,
        o.order_estimated_delivery_at,

        coalesce(p.total_payment_value, 0)              as total_payment_value,
        coalesce(p.max_payment_installments, 0)         as max_payment_installments,
        coalesce(p.payment_type_count, 0)               as payment_type_count,
        p.payment_types_used,

        r.review_score,

        datediff('day',
            o.order_purchased_at,
            o.order_delivered_customer_at)              as actual_delivery_days,

        datediff('day',
            o.order_purchased_at,
            o.order_estimated_delivery_at)              as estimated_delivery_days,

        datediff('day',
            o.order_estimated_delivery_at,
            o.order_delivered_customer_at)              as delivery_delay_days

    from orders o
    left join payments p
        on o.order_id = p.order_id
    left join reviews r
        on o.order_id = r.order_id
)

select * from joined