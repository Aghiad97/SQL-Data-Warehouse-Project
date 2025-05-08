-- WARNING: Running this script will ERASE all existing data in the target tables
-- in the DataWarehouse bronze layer before importing new data.
-- Bulk Load Script: Populate Data Warehouse Bronze Tables from Files in Docker Container
-- This script truncates existing data in the bronze layer and
-- bulk inserts data from CSV files located within the SQL Server Docker container.
--  This stored procedure is designed to load raw data from various CSV files into corresponding tables within the 'bronze' schema.
-- It first clears the existing data in each target table using TRUNCATE TABLE.

CREATE OR ALTER PROCEDURE bronze.load_bronze AS -- <SCHEMA>.load_<lyar> __ EXCE to run
BEGIN
    DECLARE @start_time DATETIME , @end_time DATETIME
    DECLARE @layer_time_start DATETIME, @Layer_time_end DATETIME
    SET @layer_time_start = GETDATE();
    BEGIN TRY
        PRINT '==================================';
        PRINT 'Loading Bronze Layer'
        PRINT '==================================';

        PRINT '-----------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-----------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        Print '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '/cust_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
        TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Loading Duration: ' + CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) +' SECOND';
        PRINT '--------------------'

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info; 
        Print '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '/prd_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Loading Duration: ' + CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) +' SECOND';
        PRINT '--------------------'

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details; 
        Print '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '/sales_detailes.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Loading Duration: ' + CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) +' SECOND';

        PRINT '-----------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-----------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12; 
        Print '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM '/CUST_AZ12.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Loading Duration: ' + CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) +' SECOND';
        PRINT '--------------------'

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101; 
        Print '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM '/LOC_A101.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Loading Duration: ' + CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) +' SECOND';
        PRINT '--------------------'

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2; 
        Print '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/PX_CAT_G1V2.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT '>> Loading Duration: ' + CAST( DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) +' SECOND';
        PRINT '--------------------'

        SET @Layer_time_end = GETDATE();
        PRINT '==================================================='
        PRINT 'Loading Bronze Layer is completed!'
        PRINT 'Bronze Layer Total Loading Duration is:' + CASt(DATEDIFF(SECOND, @layer_time_start, @Layer_time_end) AS NVARCHAR) + ' SECOND'
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
