-- ============================================
-- BUSINESS ANALYSIS
-- ============================================

-- 1. Monthly sales performance
-- Business question:
-- How has net sales developed over time?

SELECT
    d.year,
    d.month,
    TRIM(d.month_name) AS month_name,
    ROUND(SUM(f.net_sales), 2) AS net_sales
FROM fact_sales AS f
JOIN dim_date AS d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;

-- 2. Yearly sales performance
-- Business question:
-- How have annual net sales changed over time?

SELECT
    d.year,
    ROUND(SUM(f.net_sales), 2) AS net_sales,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(
        SUM(f.net_sales) / COUNT(DISTINCT f.order_id),
        2
    ) AS average_order_value
FROM fact_sales AS f
JOIN dim_date AS d
    ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

-- 3. Top product categories by revenue
-- Business question:
-- Which product categories generate the most net sales?

SELECT
    RANK() OVER (
        ORDER BY SUM(f.net_sales) DESC
    ) AS category_rank,
    p.category_name,
    ROUND(SUM(f.net_sales), 2) AS net_sales,
    SUM(f.quantity) AS units_sold,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM fact_sales AS f
JOIN dim_product AS p
    ON f.product_key = p.product_key
GROUP BY
    p.category_name
ORDER BY
    net_sales DESC;

-- 4. Store performance
-- Business question:
-- Which stores generate the highest net sales?

SELECT
    RANK() OVER (
        ORDER BY SUM(f.net_sales) DESC
    ) AS store_rank,
    st.store_id,
    st.city,
    ROUND(SUM(f.net_sales), 2) AS net_sales,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(
        SUM(f.net_sales) / NULLIF(COUNT(DISTINCT f.order_id), 0),
        2
    ) AS average_order_value
FROM fact_sales AS f
JOIN dim_store AS st
    ON f.store_key = st.store_key
GROUP BY
    st.store_id,
    st.city
ORDER BY
    net_sales DESC;

    -- 5. Promotion performance
-- Business question:
-- How do discount levels relate to sales performance?

SELECT
    pr.discount,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.gross_sales), 2) AS gross_sales,
    ROUND(SUM(f.discount_amount), 2) AS total_discounts,
    ROUND(SUM(f.net_sales), 2) AS net_sales,
    ROUND(
        SUM(f.net_sales) /
        NULLIF(COUNT(DISTINCT f.order_id), 0),
        2
    ) AS average_order_value
FROM fact_sales AS f
JOIN dim_promotion AS pr
    ON f.promotion_key = pr.promotion_key
GROUP BY
    pr.discount
ORDER BY
    pr.discount;

    -- 6. Year-over-Year Sales Growth
-- Business question:
-- How has annual net sales changed compared to the previous year?

WITH yearly_sales AS (
    SELECT
        d.year,
        ROUND(SUM(f.net_sales), 2) AS net_sales
    FROM fact_sales AS f
    JOIN dim_date AS d
        ON f.date_key = d.date_key
    WHERE d.year BETWEEN 2020 AND 2023
    GROUP BY d.year
),
sales_with_previous_year AS (
    SELECT
        year,
        net_sales,
        LAG(net_sales) OVER (
            ORDER BY year
        ) AS previous_year_sales
    FROM yearly_sales
)
SELECT
    year,
    net_sales,
    previous_year_sales,
    ROUND(
        100.0 * (net_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0),
        2
    ) AS yoy_growth_pct
FROM sales_with_previous_year
ORDER BY year;