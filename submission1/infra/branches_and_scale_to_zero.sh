#!/usr/bin/env bash
# Branch topology + scale-to-zero for the Meridian Lakebase project, as code.
# Requirement: development branch off main + a throwaway forecasting branch,
# and idle branches configured to scale to zero for cost efficiency.
set -euo pipefail
P="${DATABRICKS_PROFILE:-fe-vm-serverless-stable-tech-summit}"
PROJ="projects/meridian-bank"

# --- development branch off main (production = the clean/main environment) ---
databricks postgres create-branch "$PROJ" development \
  --json '{"spec": {"source_branch": "'"$PROJ"'/branches/production", "no_expiry": true}}' -p "$P" || true

# --- throwaway forecasting branch (auto-expires via ttl = 7 days) ---
databricks postgres create-branch "$PROJ" forecasting \
  --json '{"spec": {"source_branch": "'"$PROJ"'/branches/production", "ttl": "604800s"}}' -p "$P" || true

# --- scale-to-zero: floor every endpoint at the 0.5 CU minimum so idle
#     branches cost close to nothing (they suspend after the idle timeout). ---
for BR in production development forecasting; do
  databricks postgres update-endpoint "$PROJ/branches/$BR/endpoints/primary" \
    "spec.autoscaling_limit_min_cu,spec.autoscaling_limit_max_cu" \
    --json '{"spec": {"autoscaling_limit_min_cu": 0.5, "autoscaling_limit_max_cu": 2.0}}' -p "$P"
done
