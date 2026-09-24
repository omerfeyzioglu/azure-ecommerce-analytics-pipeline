# Cost and Cleanup

The project is designed around Synapse Serverless SQL and only four source entities from the Olist dataset. It intentionally avoids Dedicated SQL Pools, Spark Pools, ADF Mapping Data Flows, VMs, managed virtual networks, and unnecessary private endpoints. Resources will share one region, source files remain small enough for an MVP, and ADF runs will be limited to required verification.

The resource group and Standard LRS storage account are now active, so low storage and transaction charges can accrue. ADF and Synapse have not yet been created. Review actual spend in Azure Cost Management rather than assuming promotional credit remains.

## Cleanup Checklist

After the project has been executed and documented:

1. Verify the GitHub repository contains no secrets.
2. Save the required screenshots without credentials.
3. Save the executed SQL files.
4. Export and sanitize the ADF pipeline definition.
5. Confirm the README contains only verified results.
6. Delete the project Azure Resource Group.
7. Confirm its resources are gone.
8. Check Azure Cost Management for unexpected charges.

No cleanup is required yet because no Azure resources have been created during Phase 1.
