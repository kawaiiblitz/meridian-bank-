SELECT o.customer_id,
       c.tier,
       c.home_metro,
       o.days_to_maturity,
       round(o.balance_at_risk_usd::numeric, 0)  AS balance_at_risk_usd,
       round(o.revenue_at_risk_usd::numeric, 0)  AS revenue_at_risk_usd
FROM   app.open_atrisk o
JOIN   app.customer_position c USING (customer_id)
WHERE  c.risk_band = 'critical'
  AND  o.days_to_maturity <= 10
ORDER  BY o.revenue_at_risk_usd DESC
LIMIT  10;
