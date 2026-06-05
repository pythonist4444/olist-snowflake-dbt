with orders as (
    select * from {{ ref('int_orders_with_payments') }}
),

order_items as (
    select
        order_id,
        count(*)                            as total_items,
        sum(price)                          as total_items_value,
        sum(freight_value)                  as total_freight_value,
        sum(total_item_value)               as total_order_value
    from {{ ref('int_order_items_enriched') }}
    group by order_id
),

customers as (
    select
        customer_id,
        customer_city,
        customer_state
    from {{ ref('dim_customers') }}
),

dates as (
    select * from {{ ref('dim_date') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchased_at,
        o.order_approved_at,
        o.order_delivered_carrier_at,
        o.order_delivered_customer_at,
        o.order_estimated_delivery_at,
        date_trunc('month', o.order_purchased_at)   as order_month,
        o.order_purchased_at::date                  as order_date_day,

        c.customer_city,
        c.customer_state,

        coalesce(oi.total_items, 0)                 as total_items,
        coalesce(oi.total_items_value, 0)           as total_items_value,
        coalesce(oi.total_freight_value, 0)         as total_freight_value,
        coalesce(oi.total_order_value, 0)           as total_order_value,

        o.total_payment_value,
        o.max_payment_installments,
        o.payment_types_used,

        o.review_score,
        o.actual_delivery_days,
        o.estimated_delivery_days,
        o.delivery_delay_days,
        d.year_month                                as order_year_month,

        case
            when o.delivery_delay_days > 0  then 'late'
            when o.delivery_delay_days <= 0 then 'on_time'
            else 'unknown'
        end                                         as delivery_status

    from orders o
    left join order_items oi
        on o.order_id = oi.order_id
    left join customers c
        on o.customer_id = c.customer_id
    left join dates d
        on o.order_purchased_at::date = d.date_day
)

select * from final