-- Migration 003 (agentic change) — index to speed the RM queue lookup
-- (per-customer latest action by status). Applied on the development branch,
-- validated, then promoted to main via merge.
CREATE INDEX IF NOT EXISTS idx_rm_actions_customer_status
    ON app.rm_actions (customer_id, status);
