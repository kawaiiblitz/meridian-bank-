# Meridian Bank — Build 1 (Lakebase) as code

Governed Unity Catalog → Lakebase serving layer for the Meridian Bank
attrition / next-best-action app, defined as code.

## Components

| Component | Where | Notes |
|-----------|-------|-------|
| Synced UC tables (read-only) | `databricks.yml` | `customer_position`, `open_atrisk`, `nba_recommendations`, `products` mirrored from Gold into Lakebase `app.*` (SNAPSHOT) |
| Lakebase Search (hybrid) | `migrations/001_lakebase_search.sql` | native `lakebase_bm25` (full-text) + `lakebase_ann` (vector) over `products.description` |
| Writable table + reverse sync | `migrations/002_writable_and_reverse_sync.sql` | `app.rm_actions` (writable) → SCD2 history in `meridian_bank.lb_rm_actions_history` via `wal2delta` |

## Environment

- Lakebase project: `meridian-bank` (branches `production` = clean/main, `development` = iteration)
- Catalog / schema: `serverless_stable_tech_summit_catalog.meridian_bank`
- Hero customer for validation: `CUST-0000214`

## Deploy

```bash
databricks bundle deploy -t dev
# then apply migrations against the development branch endpoint
```
