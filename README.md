# Project Overview

Welcome! This project was my first end-to-end implementation of a modern data warehouse, completed as part of my course. I focused on setting up a robust, scalable system that covers everything from raw data ingestion right through to final reports.

Here's a breakdown of the core technical areas I implemented:

### 1. Data Architecture: Medallion Framework

I designed the entire warehouse around the Medallion Architecture. This was crucial for ensuring data quality and organization. The flow is structured into three distinct layers:

Bronze: This is the initial landing zone where data is kept raw, exactly as it comes from the source systems.

Silver: Here, the raw data is cleaned, standardized, and de-duplicated. It represents a single source of truth for all enterprise data.

Gold: The final layer! This contains highly refined, aggregated, and optimized data ready for reporting and business intelligence (BI) tools.

### 2. ETL Pipelines & Workflows

I built the Extract, Transform, Load (ETL) pipelines to manage the data movement. This involved writing the logic to:

Extract data from the various source systems.

Transform it—this was the core work of cleaning, normalizing, and shaping the data based on business rules.

Load the processed data sequentially into the Silver and Gold layers.

### 3. Data Modeling

To support analytical speed and clarity, I implemented a Dimensional Model focused on optimization. This involved developing and populating:

Fact Tables: Holding quantitative, observable events (like sales transactions or measurements).

Dimension Tables: Holding descriptive attributes related to the facts (like customer names, dates, or product details).

### 4. Analytics & Reporting

The goal was to make the data actionable! I created and validated several key outputs:

I wrote specific SQL-based reports against the Gold layer to extract key business metrics.

I ensured the Gold tables were structured perfectly to feed BI dashboards, providing actionable insights to end-users.
