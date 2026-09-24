/*
Run the first batch in the Serverless SQL master database, then run the
remaining batches in ecommerce_analytics. Replace the password placeholder
locally and never commit the real value.
*/

IF DB_ID(N'ecommerce_analytics') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE ecommerce_analytics');
END;
GO

USE ecommerce_analytics;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.symmetric_keys
    WHERE name = N'##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'CHANGE_ME_BEFORE_EXECUTION_Aa1!';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_scoped_credentials
    WHERE name = N'workspace_managed_identity'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL workspace_managed_identity
    WITH IDENTITY = 'Managed Identity';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.external_data_sources
    WHERE name = N'west_europe_project_lake'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE west_europe_project_lake
    WITH (
        LOCATION = 'abfss://datalake@stecomolistomer260924.dfs.core.windows.net',
        CREDENTIAL = workspace_managed_identity
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.external_file_formats
    WHERE name = N'parquet_snappy'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT parquet_snappy
    WITH (
        FORMAT_TYPE = PARQUET,
        DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'bronze')
    EXEC(N'CREATE SCHEMA bronze');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'silver')
    EXEC(N'CREATE SCHEMA silver');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'gold')
    EXEC(N'CREATE SCHEMA gold');
GO

SELECT
    DB_NAME() AS database_name,
    name AS external_data_source,
    location
FROM sys.external_data_sources
WHERE name = N'west_europe_project_lake';
