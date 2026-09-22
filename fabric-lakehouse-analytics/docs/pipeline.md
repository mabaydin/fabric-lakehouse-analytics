# Orchestration and monitoring

**Data pipeline `pl_daily_sales_load`** (Fabric Data Factory)

1. `DF_customers_silver` – Dataflow Gen2: reads `Files/bronze/customers.csv`, trims text, removes blank rows and duplicate keys in Power Query M, lands `silver_customers_df` in the lakehouse.
2. `NB_bronze_silver_gold` – runs the notebook (on success of step 1).
3. `Fail_on_notebook_error` – Fail activity on the failure path of steps 1 and 2, so the run is marked red in the Monitoring hub with a readable message.

The Direct Lake semantic model reframes automatically after the Gold tables are rewritten; no refresh activity is required. Schedule: daily 06:00 Europe/Berlin. Run history and Spark logs are reviewed in the Monitoring hub; item lineage: Lakehouse → SQL analytics endpoint → semantic model → report.

## Data-quality rules applied in Silver

| Rule | Reject reason | In sample data |
|---|---|---|
| empty order id | `missing_order_id` | 4 rows |
| empty customer id | `missing_customer` | 8 rows |
| unparseable date | `invalid_date` | 1 row (`2025-13-40`) |
| quantity <= 0 | `non_positive_qty` | 5 rows |
| product not in master | `unknown_product` | 6 rows (`P9999`) |
| customer not in master | `unknown_customer` | orphan keys |
| exact duplicate | removed before rules | 15 rows |

Reconciliation printed on every run: `raw = good + rejects + dedup`.
