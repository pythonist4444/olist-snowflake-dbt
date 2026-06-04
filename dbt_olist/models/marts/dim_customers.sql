with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select
        customer_id,
        count(distinct order_id)            as total_orders,
        min(order_purchased_at)             as first_order_at,
        max(order_purchased_at)             as last_order_at
    from {{ ref('int_orders_with_payments') }}
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_unique_id,
        c.customer_zip_code,
        c.customer_city,
        c.customer_state,

        coalesce(o.total_orders, 0)         as total_orders,
        o.first_order_at,
        o.last_order_at,

        case
            when o.total_orders >= 3 then 'loyal'
            when o.total_orders = 2  then 'returning'
            when o.total_orders = 1  then 'one_time'
            else 'no_orders'
        end                                 as customer_segment

    from customers c
    left join orders o
        on c.customer_id = o.customer_id
)

select * from final