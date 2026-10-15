-- ============================================
-- DATA WAREHOUSE VALIDATION
-- ============================================

-- Check row counts

SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count
FROM dim_customer

UNION ALL

SELECT 'dim_product', COUNT(*)
FROM dim_product

UNION ALL

SELECT 'dim_store', COUNT(*)
FROM dim_store

UNION ALL

SELECT 'dim_promotion', COUNT(*)
FROM dim_promotion

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dim_date

UNION ALL

SELECT 'fact_sales', COUNT(*)
FROM fact_sales;

-- ============================================
-- FOREIGN KEY INTEGRITY CHECK
-- ============================================

SELECT
    COUNT(*) FILTER (WHERE c.customer_key IS NULL) AS missing_customers,
    COUNT(*) FILTER (WHERE p.product_key IS NULL) AS missing_products,
    COUNT(*) FILTER (WHERE st.store_key IS NULL) AS missing_stores,
    COUNT(*) FILTER (WHERE pr.promotion_key IS NULL) AS missing_promotions,
    COUNT(*) FILTER (WHERE d.date_key IS NULL) AS missing_dates
FROM fact_sales AS f
LEFT JOIN dim_customer AS c
    ON f.customer_key = c.customer_key
LEFT JOIN dim_product AS p
    ON f.product_key = p.product_key
LEFT JOIN dim_store AS st
    ON f.store_key = st.store_key
LEFT JOIN dim_promotion AS pr
    ON f.promotion_key = pr.promotion_key
LEFT JOIN dim_date AS d
    ON f.date_key = d.date_key;
    -- ============================================
-- SALES MEASURES VALIDATION
-- ============================================

SELECT
    ROUND(SUM(gross_sales), 2) AS total_gross_sales,
    ROUND(SUM(discount_amount), 2) AS total_discount_amount,
    ROUND(SUM(net_sales), 2) AS total_net_sales
FROM fact_sales;

-- Check that net sales calculation is correct

SELECT
    ROUND(SUM(gross_sales - discount_amount - net_sales), 2)
        AS sales_difference
FROM fact_sales;