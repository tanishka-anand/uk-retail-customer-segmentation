-- ─────────────────────────────────────────────
-- UK RETAIL CUSTOMER SEGMENTATION
-- Script 01: Database Setup and Table Creation
-- ─────────────────────────────────────────────

-- Create database
CREATE DATABASE IF NOT EXISTS retail_analytics;
USE retail_analytics;

-- Main fact table
CREATE TABLE IF NOT EXISTS transactions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id      VARCHAR(20)     NOT NULL,
    stock_code      VARCHAR(20)     NOT NULL,
    description     VARCHAR(255)    NULL,
    quantity        INT             NOT NULL,
    invoice_date    DATETIME        NOT NULL,
    price           DECIMAL(10,2)   NOT NULL,
    customer_id     INT             NULL,
    country         VARCHAR(100)    NOT NULL
);

-- Derived segments table
CREATE TABLE IF NOT EXISTS customer_segments (
    customer_id     INT             NOT NULL,
    r_score         INT             NOT NULL,
    f_score         INT             NOT NULL,
    m_score         INT             NOT NULL,
    rfm_score       VARCHAR(10)     NOT NULL,
    segment_name    VARCHAR(50)     NOT NULL,
    assigned_date   DATE            NOT NULL,
    cluster_segment VARCHAR(50)     NULL,
    PRIMARY KEY (customer_id)
);
