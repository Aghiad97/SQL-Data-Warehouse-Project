/*
Create Database and Schemas
二ニニニニニニニニニニニニニニニニ
Script Purpose:
This script creates a new database named 'DataWarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.
WARNING:
Running this script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.
*/


USE MASTER; 
GO

-- Drop and recreate DataWarehouse Database
IF EXISTS (SELECT 1 FROM sys.databases WHERE NAME = DataWarehouse)
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLlBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create THE 'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- create schemas
CREATE SCHEMA bronze;
GO -- it's a separetor that tell sql to fully create the first one then create the other
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO



