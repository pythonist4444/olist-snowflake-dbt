with source as (
    select * from {{ source('olist_raw', 'order_reviews') }}
),

renamed as (
    select
        REVIEW_ID                                           as review_id,
        ORDER_ID                                            as order_id,
        REVIEW_SCORE::int                                   as review_score,
        REVIEW_COMMENT_TITLE                                as review_comment_title,
        REVIEW_COMMENT_MESSAGE                              as review_comment_message,
        try_to_timestamp(REVIEW_CREATION_DATE)              as review_created_at,
        try_to_timestamp(REVIEW_ANSWER_TIMESTAMP)           as review_answered_at
    from source
)

select * from renamed