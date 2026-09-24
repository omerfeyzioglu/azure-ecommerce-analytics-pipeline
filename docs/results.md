# Validation Baseline

These deterministic acceptance values were calculated from the same four immutable Olist CSV files used by the pipeline.

| Measure | Expected value |
| --- | ---: |
| Orders | 99,441 |
| Order items / Silver rows | 112,650 |
| Customers | 99,441 |
| Products | 32,951 |
| Products with missing category | 610 |
| Delivered orders missing delivered timestamp | 8 |
| GMV excluding cancelled orders and freight | 13,496,408.43 BRL |
| Distinct commercial orders | 98,205 |
| Items sold | 112,108 |
| Unique customers | 94,989 |
| Average order value | 137.43 BRL |
| Delivered orders | 96,478 |
| Late deliveries | 7,826 |
| Late-delivery rate | 8.11% |
| Average delivery time | 12.56 days |

All duplicate-key, referential-integrity, invalid-price, negative-freight, unexpected-status, and delivery-before-purchase checks have an expected result of zero.

Top categories by GMV are `beleza_saude` (1,255,695.13 BRL), `relogios_presentes` (1,198,185.21), `cama_mesa_banho` (1,035,964.06), `esporte_lazer` (979,740.92), and `informatica_acessorios` (904,322.02).
