CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INTEGER UNIQUE NOT NULL,
    city VARCHAR(100),
    signup_date DATE
);

CREATE TABLE dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id INTEGER UNIQUE NOT NULL,
    city VARCHAR(100)
);

CREATE TABLE dim_promotion (
    promotion_key SERIAL PRIMARY KEY,
    promotion_id INTEGER UNIQUE NOT NULL,
    discount NUMERIC(5,2)
);

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER UNIQUE NOT NULL,
    category_name VARCHAR(255),
    supplier_country VARCHAR(100),
    unit_price NUMERIC(10,2)
);

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_month INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL
);

CREATE TABLE fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,

    order_item_id INTEGER UNIQUE NOT NULL,
    order_id INTEGER NOT NULL,

    date_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    promotion_key INTEGER NOT NULL,

    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    gross_sales NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(12,2) NOT NULL,
    net_sales NUMERIC(12,2) NOT NULL,

    FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    FOREIGN KEY (product_key)
        REFERENCES dim_product(product_key),

    FOREIGN KEY (store_key)
        REFERENCES dim_store(store_key),

    FOREIGN KEY (promotion_key)
        REFERENCES dim_promotion(promotion_key)
);