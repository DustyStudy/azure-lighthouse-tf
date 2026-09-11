#!/usr/bin/env bash
# Confirms every principal_id referenced in the target tfvars file resolves
# to a real object (user, group, or service principal) in the MANAGING
# tenant. Requires `az login` (via OIDC, done by the calling workflow step)
# against the managing tenant before this script runs.
#
# Usage: validate-principal-ids.sh <tfvars-file>

set -euo pipefail

TFVARS_FILE="${1:?Usage: validate-principal-ids.sh <tfvars-file>}"

if ! command -v jq >/dev/null 2>&1; then
  echo "::error::jq is required" >&2
  exit 1
fi

# Pull principal_id values out of the HCL tfvars file. This is a best-effort
# text extraction (tfvars is HCL, not JSON) - it looks for the
# principal_id = "<guid>" pattern line by line.
mapfile -t PRINCIPAL_IDS < <(grep -oE 'principal_id[[:space:]]*=[[:space:]]*"[0-9a-fA-F-]{36}"' "$TFVARS_FILE" \
  | grep -oE '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' \
  | sort -u)

if [[ ${#PRINCIPAL_IDS[@]} -eq 0 ]]; then
  echo "::error::No principal_id values found in $TFVARS_FILE - refusing to proceed with an empty delegation."
  exit 1
fi

FAILED=0
for pid in "${PRINCIPAL_IDS[@]}"; do
  echo "Checking principal $pid ..."
  if az ad sp show --id "$pid" >/dev/null 2>&1; then
    echo "  found: service principal"
    continue
  fi
  if az ad group show --group "$pid" >/dev/null 2>&1; then
    echo "  found: group"
    continue
  fi
  if az ad user show --id "$pid" >/dev/null 2>&1; then
    echo "  found: user"
    continue
  fi
  echo "::error::principal_id $pid does not resolve to a user, group, or service principal in the current tenant."
  FAILED=1
done

if [[ "$FAILED" -eq 1 ]]; then
  echo "::error::One or more principal IDs failed validation. Fix the tfvars file before merging."
  exit 1
fi

echo "All principal IDs resolved successfully."
