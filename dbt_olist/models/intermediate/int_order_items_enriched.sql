with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

translations as (
    select * from {{ ref('stg_product_category_name_translation') }}
),

sellers as (
    select * from {{ ref('stg_sellers') }}
),

enriched as (
    select
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        oi.shipping_limit_at,
        oi.price,
        oi.freight_value,
        oi.price + oi.freight_value                     as total_item_value,

        p.product_category_name_pt,
        coalesce(t.product_category_name_en, 'unknown') as product_category_name_en,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,

        s.seller_city,
        s.seller_state
    from order_items oi
    left join products p
        on oi.product_id = p.product_id
    left join translations t
        on p.product_category_name_pt = t.product_category_name_pt
    left join sellers s
        on oi.seller_id = s.seller_id
)

select * from enriched