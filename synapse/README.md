# Synapse Serverless SQL

Run the scripts in numeric order against the built-in endpoint ending in `-ondemand.sql.azuresynapse.net`:

1. Setup the metadata database, managed-identity credential, external data source, Parquet format, and schemas.
2. Create explicitly typed Bronze views and prove `TOP 10`/row-count access.
3. Run key, relationship, null, status, price, freight, and delivery quality checks.
4. Join all sources and write item-grain Silver Parquet with CETAS.
5. Write Daily GMV, category, and delivery Gold Parquet datasets.

Before step 1, replace the master-key password placeholder locally and grant the workspace managed identity `Storage Blob Data Contributor` on the `datalake` filesystem. Never commit the real password.

CETAS does not overwrite existing files. The scripts use versioned `v1/` output paths; use a new version for a repeat run.
