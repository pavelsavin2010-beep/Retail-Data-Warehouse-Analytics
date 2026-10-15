DROP TABLE IF EXISTS stg_sales;

CREATE TABLE stg_sales (
    order_item_id INTEGER,
    order_id INTEGER,
    product_id INTEGER,
    qty INTEGER,
    price NUMERIC(10,2),
    line_sales NUMERIC(12,2),
    customer_id INTEGER,
    store_id INTEGER,
    order_date DATE,
    promotion_id INTEGER,
    order_year INTEGER,
    order_month INTEGER,
    order_quarter INTEGER,
    order_day_of_week VARCHAR(20),
    discount NUMERIC(5,2),
    gross_sales NUMERIC(12,2),
    discount_amount NUMERIC(12,2),
    net_sales NUMERIC(12,2)
);

\copy stg_sales(order_item_id, order_id, product_id, qty, price, line_sales, customer_id, store_id, order_date, promotion_id, order_year, order_month, order_quarter, order_day_of_week, discount, gross_sales, discount_amount, net_sales) FROM 'data/processed/sales_clean.csv' WITH (FORMAT csv, HEADER true);
SELECT COUNT(*) AS staging_sales_count
FROM stg_sales;

SELECT COUNT(*) AS rows_after_joins
FROM stg_sales AS s
JOIN dim_customer AS c
    ON s.customer_id = c.customer_id
JOIN dim_product AS p
    ON s.product_id = p.product_id
JOIN dim_store AS st
    ON s.store_id = st.store_id
JOIN dim_promotion AS pr
    ON s.promotion_id = pr.promotion_id
JOIN dim_date AS d
    ON s.order_date = d.full_date;

INSERT INTO fact_sales (
    order_item_id,
    order_id,
    date_key,
    customer_key,
    product_key,
    store_key,
    promotion_key,
    quantity,
    unit_price,
    gross_sales,
    discount_amount,
    net_sales
)
SELECT
    s.order_item_id,
    s.order_id,
    d.date_key,
    c.customer_key,
    p.product_key,
    st.store_key,
    pr.promotion_key,
    s.qty,
    s.price,
    s.gross_sales,
    s.discount_amount,
    s.net_sales
FROM stg_sales AS s
JOIN dim_customer AS c
    ON s.customer_id = c.customer_id
JOIN dim_product AS p
    ON s.product_id = p.product_id
JOIN dim_store AS st
    ON s.store_id = st.store_id
JOIN dim_promotion AS pr
    ON s.promotion_id = pr.promotion_id
JOIN dim_date AS d
    ON s.order_date = d.full_date
ON CONFLICT (order_item_id) DO NOTHING;

SELECT COUNT(*) AS fact_sales_count
FROM fact_sales;

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE c.customer_key IS NULL
    ) AS missing_customer,

    COUNT(*) FILTER (
        WHERE p.product_key IS NULL
    ) AS missing_product,

    COUNT(*) FILTER (
        WHERE st.store_key IS NULL
    ) AS missing_store,

    COUNT(*) FILTER (
        WHERE pr.promotion_key IS NULL
    ) AS missing_promotion,

    COUNT(*) FILTER (
        WHERE d.date_key IS NULL
    ) AS missing_date

FROM stg_sales AS s

LEFT JOIN dim_customer AS c
    ON s.customer_id = c.customer_id

LEFT JOIN dim_product AS p
    ON s.product_id = p.product_id

LEFT JOIN dim_store AS st
    ON s.store_id = st.store_id

LEFT JOIN dim_promotion AS pr
    ON s.promotion_id = pr.promotion_id

LEFT JOIN dim_date AS d
    ON s.order_date = d.full_date;

    SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date
FROM stg_sales;