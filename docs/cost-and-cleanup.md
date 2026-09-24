# Cost and Cleanup

The project is designed around Synapse Serverless SQL and only four source entities from the Olist dataset. It intentionally avoids Dedicated SQL Pools, Spark Pools, ADF Mapping Data Flows, VMs, managed virtual networks, and unnecessary private endpoints. Source files remain small enough for an MVP, and ADF runs are limited to required verification.

Four small manual Copy Activity runs were executed and no trigger or recurring schedule is enabled. The Synapse implementation uses only the built-in Serverless SQL endpoint. Review actual spend in Azure Cost Management rather than assuming promotional credit remains.

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

Deleting every project resource group after evidence is captured is the safest way to stop recurring storage and control-plane costs. Also verify that no SQL or Spark pools, triggers, private endpoints, or managed resource groups remain.
