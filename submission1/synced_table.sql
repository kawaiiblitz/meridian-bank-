-- Query against the read-only synced Unity Catalog table app.customer_position
SELECT customer_id, tier, home_metro, risk_band,
       round(balance_at_risk_usd::numeric,0)  AS balance_at_risk_usd,
       round(revenue_at_risk_usd::numeric,0)  AS revenue_at_risk_usd
FROM   app.customer_position
WHERE  risk_band = 'critical'
ORDER  BY balance_at_risk_usd DESC
LIMIT  10;
