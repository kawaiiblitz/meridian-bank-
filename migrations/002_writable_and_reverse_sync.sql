-- Migration 002 — Writable operational table + reverse Lakehouse Sync
-- Requirement: a synced UC table is read-only in Postgres, so the app
-- writes to a separate writable Postgres table; those changes stream back
-- into a Unity Catalog Delta table (SCD Type 2).

-- Writable action table (the ONLY table the app writes to). Not synced from
-- Delta; it is the write side of the closed loop.
CREATE TABLE IF NOT EXISTS app.rm_actions (
    id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id            text NOT NULL,
    action_type            text NOT NULL,       -- retention_offer / cross_sell / rm_outreach
    offered_product_id     text,
    rate_apy               double precision,
    drafted_note           text,
    predicted_retained_usd double precision,
    status                 text NOT NULL,       -- proposed / approved / executed / overridden
    approved_by            text,                -- OBO-stamped user email
    audit_trail            jsonb DEFAULT '[]'::jsonb,
    created_at             timestamptz DEFAULT now(),
    decided_at             timestamptz
);

-- Enable reverse Lakehouse Sync (wal2delta) for this table: REPLICA IDENTITY
-- FULL makes Postgres emit the full old+new row images in the WAL, which the
-- managed wal2delta engine streams into the Delta table
--   serverless_stable_tech_summit_catalog.meridian_bank.lb_rm_actions_history
-- as an SCD Type 2 change history (insert / update_preimage / update_postimage)
-- with system-metadata columns (_pg_change_type, _pg_lsn, _pg_xid, _timestamp).
ALTER TABLE app.rm_actions REPLICA IDENTITY FULL;
