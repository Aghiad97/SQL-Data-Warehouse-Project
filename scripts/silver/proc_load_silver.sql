 /* WARNING: Running this script will ERASE all existing data in the target tables
 in the DataWarehouse silver layer before importing new data.
Bulk Load Script: Populate Data Warehouse silver Tables from Files in Docker Container
 This script truncates existing data in the silver layer and
 bulk inserts data from CSV files located within the SQL Server Docker container.
  This stored procedure is designed to load raw data from various CSV files into corresponding tables within the 'bronze' schema.
 It first clears the existing data in each target table using TRUNCATE TABLE.
 usage example: EXEC brosilvernze.load_silver;*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @layer_start_time DATETIME, @layer_end_time DATETIME
    BEGIN TRY
        SET @layer_start_time = GETDATE();
        PRINT '=============================='
        PRINT 'LOADING SILVER LAYER'
        PRINT '=============================='

        PRINT '------------------------------'
        PRINT 'LOADING CRM TABELS'
        PRINT '------------------------------'

        -- Truncating and loading silver.crm_cust_info:
        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.crm_cust_info'
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT'>> Insert Data To: silver.crm_cust_info'
        INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date)

        SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) as cst_firstname,  -- Data cleansing 
        TRIM(cst_lastname) as cst_lastname,
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'   -- data standarization/ normalization 
            WHEN UPPER(TRIM(cst_marital_status)  ) = 'M' THEN 'Maried'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)  ) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
        FROM (
        SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as ranking -- removing duplicates
        FROM bronze.crm_cust_info 
        ) AS t 
        WHERE ranking  = 1;
        SET @end_time = GETDATE();
        PRINT '>> LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
        PRINT '--------------------------'



        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info'
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT'>> Insert Data To: silver.crm_prd_info'
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt 
        )
        SELECT 
        prd_id, -- we don't have duplicates
        REPLACE(SUBSTRING(prd_key, 1, 5),'-','_')AS cat_id, -- Extract category ID
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Extract Product Key
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost , -- Handling missing Information instead of null we replace it by 0
        CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a' END AS prd_line, -- Data normalization: Map Product line Codes to descriptive Valuesv, handling missing data instead of null, we put  n/a
        CAST(prd_start_dt AS DATE) AS prd_start_dt, -- Data Type Casting 
        CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) AS prd_end_date -- Data Type Casting and Data Enrichment
        FROM bronze.crm_prd_info
        SET @end_time = GETDATE()
        PRINT '>> LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
        PRINT'-------------------------'

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.crm_sales_details'
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT'>> Insert Data To: silver.crm_sales_details'
        INSERT INTO silver.crm_sales_details(
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt, 
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price 
        )
        SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id, 
        CASE WHEN sls_order_dt < 0 OR LEN(sls_order_dt) < 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
        END AS sls_order_dt, -- In SQL we cast into varchar then to date
        CASE WHEN sls_ship_dt < 0 OR LEN(sls_ship_dt) < 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt < 0 OR LEN(sls_due_dt) < 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
        END AS sls_due_dt,

        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> sls_quantity * ABS(sls_price) 
            THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
        END AS sls_sales,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0 
                THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE sls_price
        END AS sls_price 
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE()
        PRINT 'LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
        PRINT '-----------------------'

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.erp_cust_az12'
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT'>> Insert Data To: silver.erp_cust_az12'
        INSERT INTO silver.erp_cust_az12(
            cid,
            bdate,
            gen
        )
        SELECT 
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
            ELSE cid
        END AS cid,
        CASE WHEN bdate > GETDATE() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE WHEN UPPER(TRIM(gen)) IN ('Male', 'M') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('Female', 'F') THEN 'Female'
                ELSE 'n/a'
        END AS gen
        FROM bronze.erp_cust_az12 
        PRINT'LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
        PRINT '---------------------'


        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101'
        TRUNCATE TABLE silver.erp_loc_a101
        PRINT'>> Insert Data To: silver.erp_loc_a101'
        INSERT INTO silver.erp_loc_a101(
            cid,
            cntry
        )
        SELECT 
        Replace(cid, '-', '') AS cid,
        CASE WHEN TRIM(cntry) IN ('US', 'USA', 'UnitedStates') THEN 'United States'
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) = 'UnitedKingdom' THEN 'United Kingdom'
            WHEN TRIM(cntry) = '' OR trim(cntry) = NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry
        FROM bronze.erp_loc_a101
        SET @end_time = GETDATE()
        PRINT'LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
        PRINT '---------------------'

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2'
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT'>> Insert Data To: silver.erp_px_cat_g1v2'
        INSERT INTO silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
        id,
        cat,
        subcat,
        REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(maintenance, CHAR(13), ''),  -- Remove Carriage Return
                        CHAR(10), ''),                    -- Remove Line Feed
                    CHAR(9), ''),                         -- Remove Tab
                CHAR(160), ''),                           -- Remove Non-breaking Space
        ' ', '') AS maintenance
        FROM bronze.erp_px_cat_g1v2
        PRINT 'LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
        PRINT '----------------------'

        SET @layer_end_time = GETDATE()
        PRINT '==================================================='
        PRINT 'Loading Bronze Layer is completed!'
        PRINT 'Bronze Layer Total Loading Duration is:' + CAST(DATEDIFF(SECOND, @layer_start_time, @layer_end_time) AS NVARCHAR) + ' SECOND'
        PRINT '===================================================' 
    END TRY
        BEGIN CATCH
            PRINT '==========================================';
            PRINT 'AN ERROR OCCURED WHEN LOADING BRONZE LAYER';
            PRINT 'Error Message:' + ERROR_MESSAGE(); 
            PRINT 'Error Message:' + CAST(ERROR_NUMBER() AS NVARCHAR);
            PRINT 'Error Message:' + CAST(ERROR_STATE() AS NVARCHAR);
            PRINT '==========================================';
        END CATCH
END
