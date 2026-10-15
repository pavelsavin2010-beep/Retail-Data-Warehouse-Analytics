DROP TABLE IF EXISTS stg_customers;

CREATE TABLE stg_customers (
    customer_id INTEGER,
    city VARCHAR(100),
    signup_date DATE
);

\copy stg_customers(customer_id, city, signup_date) FROM 'data/processed/customers_clean.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO dim_customer (
    customer_id,
    city,
    signup_date
)
SELECT
    customer_id,
    city,
    signup_date
FROM stg_customers
ON CONFLICT (customer_id) DO NOTHING;

SELECT COUNT(*) AS customer_count
FROM dim_customer;

-- ============================================
-- STORE DIMENSION
-- ============================================

DROP TABLE IF EXISTS stg_stores;

CREATE TABLE stg_stores (
    store_id INTEGER,
    city VARCHAR(100)
);

\copy stg_stores(store_id, city) FROM 'data/raw/stores.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO dim_store (
    store_id,
    city
)
SELECT
    store_id,
    city
FROM stg_stores
ON CONFLICT (store_id) DO NOTHING;

SELECT COUNT(*) AS store_count
FROM dim_store;

-- ============================================
-- PROMOTION DIMENSION
-- ============================================

DROP TABLE IF EXISTS stg_promotions;

CREATE TABLE stg_promotions (
    promotion_id INTEGER,
    discount NUMERIC(5,2)
);

\copy stg_promotions(promotion_id, discount) FROM 'C:/Users/pavel/Downloads/Retail_data_Warehouse/data/raw/promotions.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO dim_promotion (
    promotion_id,
    discount
)
SELECT
    promotion_id,
    discount
FROM stg_promotions
ON CONFLICT (promotion_id) DO NOTHING;

SELECT COUNT(*) AS promotion_count
FROM dim_promotion;

-- ============================================
-- PRODUCT DIMENSION
-- ============================================

DROP TABLE IF EXISTS stg_products;
DROP TABLE IF EXISTS stg_categories;
DROP TABLE IF EXISTS stg_suppliers;

CREATE TABLE stg_products (
    product_id INTEGER,
    category_id INTEGER,
    supplier_id INTEGER,
    price NUMERIC(10,2)
);

CREATE TABLE stg_categories (
    category_id INTEGER,
    category_name VARCHAR(255)
);

CREATE TABLE stg_suppliers (
    supplier_id INTEGER,
    country VARCHAR(100)
);

\copy stg_products(product_id, category_id, supplier_id, price) FROM 'C:/Users/pavel/Downloads/Retail_data_Warehouse/data/raw/products.csv' WITH (FORMAT csv, HEADER true);

\copy stg_categories(category_id, category_name) FROM 'C:/Users/pavel/Downloads/Retail_data_Warehouse/data/raw/categories.csv' WITH (FORMAT csv, HEADER true);

\copy stg_suppliers(supplier_id, country) FROM 'C:/Users/pavel/Downloads/Retail_data_Warehouse/data/raw/suppliers.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO dim_product (
    product_id,
    category_name,
    supplier_country,
    unit_price
)
SELECT
    p.product_id,
    c.category_name,
    s.country,
    p.price
FROM stg_products AS p
JOIN stg_categories AS c
    ON p.category_id = c.category_id
JOIN stg_suppliers AS s
    ON p.supplier_id = s.supplier_id
ON CONFLICT (product_id) DO NOTHING;

SELECT COUNT(*) AS product_count
FROM dim_product;

-- ============================================
-- DATE DIMENSION
-- ============================================

INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day_of_month,
    day_of_week,
    day_name
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,
    d::DATE AS full_date,
    EXTRACT(YEAR FROM d)::INTEGER AS year,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
    EXTRACT(MONTH FROM d)::INTEGER AS month,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(DAY FROM d)::INTEGER AS day_of_month,
    EXTRACT(ISODOW FROM d)::INTEGER AS day_of_week,
    TO_CHAR(d, 'Day') AS day_name
FROM generate_series(
    DATE '2020-01-01',
    DATE '2024-01-01',
    INTERVAL '1 day'
) AS d
ON CONFLICT (date_key) DO NOTHING;

SELECT COUNT(*) AS date_count
FROM dim_date;