# Azure Setup

Azure setup will be performed interactively after the local dataset is generated and validated.

Planned resources, all in one Azure region:

- Resource group: `rg-ecommerce-analytics-demo`
- One ADLS Gen2-compatible storage account with hierarchical namespace enabled
- One Azure Data Factory instance
- One Azure Synapse workspace using Serverless SQL only

Resource names that require global uniqueness will be chosen at creation time. No Azure resource is currently claimed to exist.
