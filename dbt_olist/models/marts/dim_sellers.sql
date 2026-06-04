with sellers as (
    select * from {{ ref('stg_sellers') }}
),

order_items as (
    select
        seller_id,
        count(distinct order_id)            as total_orders,
        sum(price)                          as total_revenue,
        avg(price)                          as avg_order_value,
        count(distinct product_id)          as distinct_products_sold
    from {{ ref('stg_order_items') }}
    group by seller_id
),

final as (
    select
        s.seller_id,
        s.seller_zip_code,
        s.seller_city,
        s.seller_state,

        coalesce(oi.total_orders, 0)            as total_orders,
        coalesce(oi.total_revenue, 0)           as total_revenue,
        coalesce(oi.avg_order_value, 0)         as avg_order_value,
        coalesce(oi.distinct_products_sold, 0)  as distinct_products_sold

    from sellers s
    left join order_items oi
        on s.seller_id = oi.seller_id
)

select * from final