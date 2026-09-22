# Fabric Lakehouse Analytics – end-to-end sample

A complete, runnable analytics solution on **Microsoft Fabric**, built as a portfolio project (September 2026):
three deliberately dirty source files → medallion lakehouse with rule-based cleansing, reject handling and
row-count reconciliation → star schema → Direct Lake semantic model with DAX measures → orchestrated daily pipeline.

The scenario is a small tools retailer (orders, products, customers). The point is not the domain but the
discipline: **validate inside the pipeline, not in the report**, and keep every reporting value traceable to its source logic.

## Architecture

```
Files/bronze/*.csv  -->  Notebook (PySpark)  -->  silver_* (Delta)  -->  gold_* (Delta, star schema)
                          | trim . type . dedupe                       |
                          | reject rules -> silver_orders_rejects      +--> SQL analytics endpoint (T-SQL)
                          + reconciliation: raw = good + rejects + dedup    +--> Direct Lake semantic model -> report
Dataflow Gen2 (Power Query M)  -->  silver_customers_df
Data Factory pipeline: Dataflow -> Notebook -> Fail-on-error . daily 06:00 . Monitoring hub
```

## Repository

| Path | What it is |
|---|---|
| `data/bronze/` | Sample source files with known defects (duplicates, mixed date formats, orphan keys, negative quantities, invalid dates) |
| `notebooks/nb_bronze_silver_gold.ipynb` | PySpark notebook: Silver cleansing + reject handling + reconciliation; Gold star schema with contiguous calendar |
| `sql/orphan_key_check.sql` | Referential-integrity and revenue queries for the SQL analytics endpoint |
| `dax/measures.dax` | Semantic-model measures (Revenue, Orders, AOV, YTD, PY, vs PY %, Discount %) and a validation query |
| `docs/pipeline.md` | Pipeline design, failure handling, schedule, data-quality rule table |

## How to run

1. Create a Fabric workspace on a trial or F-capacity and a Lakehouse in it.
2. Upload the three CSVs to `Files/bronze/`.
3. Import the notebook, attach the lakehouse as default, run all cells. Expect roughly 1,200 good rows, ~24 rejects across six reasons, 15 duplicates removed.
4. From the SQL analytics endpoint, create a semantic model on the four `gold_*` tables; add relationships (fact -> dims, many-to-one, single direction), mark `gold_dim_date` as date table, add the measures from `dax/measures.dax`.
5. Optional: recreate the pipeline described in `docs/pipeline.md`.

## Design notes

- **Reject, don't drop.** Rejects land in a table with a reason, so a business user can see what was excluded and why.
- **Contiguous calendar.** Time intelligence (YTD, PY) is only correct on a gap-free date dimension; the calendar is generated, not derived from order dates.
- **Direct Lake.** The model reads the Delta tables; a rewrite of Gold is visible without an import refresh.
- **Orphan-key query.** A "(Blank)" member in a report is a referential-integrity gap; the fix belongs in Silver, not in the visual.

Author: Md Minhazul Abaydin - linkedin.com/in/abaydin
