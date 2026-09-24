# Architecture

The planned architecture uses one ADLS Gen2 filesystem with four logical layers:

- **Landing:** the unchanged upstream file drop, uploaded independently of ADF.
- **Bronze:** the raw, platform-controlled copy created by the ADF ingestion pipeline.
- **Silver:** typed, validated, deduplicated order data stored as Parquet.
- **Gold:** business-oriented analytical datasets derived from Silver.

Parquet is planned for Silver and Gold because its columnar layout and embedded schema are better suited to analytical queries than CSV and can reduce the amount of data scanned by Synapse Serverless SQL.

This document describes the design only. Azure deployment and execution have not yet been verified.
