with products as (
    select * from {{ ref('stg_products') }}
),

translations as (
    select * from {{ ref('stg_product_category_name_translation') }}
),

order_items as (
    select
        product_id,
        count(distinct order_id)            as times_ordered,
        sum(price)                          as total_revenue,
        avg(price)                          as avg_price
    from {{ ref('stg_order_items') }}
    group by product_id
),

final as (
    select
        p.product_id,
        p.product_category_name_pt,
        coalesce(t.product_category_name_en, 'unknown') as product_category_name_en,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,
        p.product_photos_qty,

        coalesce(oi.times_ordered, 0)       as times_ordered,
        coalesce(oi.total_revenue, 0)       as total_revenue,
        coalesce(oi.avg_price, 0)           as avg_price

    from products p
    left join translations t
        on p.product_category_name_pt = t.product_category_name_pt
    left join order_items oi
        on p.product_id = oi.product_id
)

select * from final