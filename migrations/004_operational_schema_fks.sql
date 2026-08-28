-- Migration 004 — Operational schema: related tables + keys (not a flat dump)
-- Models the app's operational (writable) domain as related tables with keys.
--
-- Relationships:
--   conversations (1) --< messages (N)         messages.conversation_id -> conversations.id
--   messages      (1) --< feedback (N)         feedback.message_id      -> messages.id
--   rm_actions.customer_id  logically references the read-only synced
--     customer_position.customer_id (a synced table is read-only in Postgres,
--     so the FK is expressed logically, enforced app-side).

ALTER TABLE app.messages
    ADD CONSTRAINT fk_messages_conversation
    FOREIGN KEY (conversation_id) REFERENCES app.conversations(id) ON DELETE CASCADE;

ALTER TABLE app.feedback
    ADD CONSTRAINT fk_feedback_message
    FOREIGN KEY (message_id) REFERENCES app.messages(id) ON DELETE CASCADE;
