-- Migration 001 — Lakebase Search (hybrid vector + full-text) as code
-- Requirement: enable Lakebase Search over a searchable text column so
-- retrieval never leaves the customer's account.
-- Prereq: the "Lakebase Search" Beta preview must be enabled at the
-- project level (Lakebase UI -> project -> Settings), which loads
-- lakebase_vector / lakebase_text into shared_preload_libraries.

-- Extensions (order matters: pgvector before lakebase_vector).
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS lakebase_vector CASCADE;
CREATE EXTENSION IF NOT EXISTS lakebase_text;

-- Companion search table over the (read-only) synced products catalog.
-- The synced app.products is read-only, so the searchable text column +
-- embedding live here; refreshed from app.products.
CREATE TABLE IF NOT EXISTS app.products_search (
    product_id            text PRIMARY KEY,
    description           text,
    description_tsv       tsvector,
    description_embedding vector(1024)
);

-- Native Lakebase Search indexes:
--   lakebase_bm25  -> full-text (BM25, Block-Max WAND)
--   lakebase_ann   -> vector ANN (IVF + RaBitQ)
CREATE INDEX IF NOT EXISTS idx_products_bm25
    ON app.products_search USING lakebase_bm25 (description);

CREATE INDEX IF NOT EXISTS idx_products_ann
    ON app.products_search USING lakebase_ann (description_embedding);
