# Synapse Serverless SQL

Run the scripts in numeric order against the built-in endpoint ending in `-ondemand.sql.azuresynapse.net`:

1. Setup the metadata database, managed-identity credential, external data source, Parquet format, and schemas.
2. Create explicitly typed Bronze views and run `TOP 10`/row-count checks.
3. Run key, relationship, null, status, price, freight, and delivery quality checks.
4. Join all sources and write item-grain Silver Parquet with CETAS.
5. Write Daily GMV, category, and delivery Gold Parquet datasets.

Before step 1, replace the master-key password placeholder locally and grant the workspace managed identity `Storage Blob Data Contributor` on the `datalake` filesystem. Never commit the real password.

The products source uses the misspelled headers `product_name_lenght` and `product_description_lenght`. The Bronze view maps them by position and exposes corrected names.

CETAS does not overwrite populated folders, and dropping an external table removes only metadata. A rerun requires either dropping the metadata and using a new versioned location, or cleaning the previous destination before reusing it.

These scripts are implemented but have not yet been verified through a complete Azure Synapse execution.
