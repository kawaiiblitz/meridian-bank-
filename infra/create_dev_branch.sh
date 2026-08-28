#!/usr/bin/env bash
# Development branch OFF MAIN, creation captured in code (both git + Lakebase).
# main / production is the clean environment; development is branched off it and
# is where all iteration happens; validated changes are promoted back to main.
set -euo pipefail
P="${DATABRICKS_PROFILE:-fe-vm-serverless-stable-tech-summit}"
PROJ="projects/meridian-bank"

# 1) Git: create the development branch OFF MAIN
git checkout main
git checkout -b development        # <-- development branch off main

# 2) Lakebase: create the development branch off the clean branch.
#    (Lakebase's clean/"main" branch is named `production`.)
databricks postgres create-branch "$PROJ" development \
  --json '{"spec": {"source_branch": "'"$PROJ"'/branches/production", "no_expiry": true}}' -p "$P"

# Iterate on development, then promote back to main via a merge / PR:
#   git checkout main && git merge --no-ff development     # or a GitHub PR
