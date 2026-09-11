#!/usr/bin/env bash
# Inspects a `terraform show -json <planfile>` output and fails if any
# azurerm_lighthouse_definition or azurerm_lighthouse_assignment resource
# is being deleted or replaced. Deleting/replacing a live delegation can
# sever a managed-services provider's access with no warning to the
# customer, so this must never happen silently via automatic apply.
#
# Usage: check-existing-delegation.sh <plan.json>
#
# Override: if the change is intentional, a human should add the label
# "lighthouse-destructive-override" to the PR - the calling workflow step
# is responsible for checking that label before invoking this script's
# exit code as a hard gate.

set -euo pipefail

PLAN_JSON="${1:?Usage: check-existing-delegation.sh <plan.json>}"

if ! command -v jq >/dev/null 2>&1; then
  echo "::error::jq is required" >&2
  exit 1
fi

DANGEROUS=$(jq -r '
  .resource_changes[]?
  | select(.type == "azurerm_lighthouse_definition" or .type == "azurerm_lighthouse_assignment")
  | select(.change.actions | any(. == "delete" or . == "create-then-destroy" or . == "delete-then-create"))
  | "\(.type).\(.name): \(.change.actions | join(\",\"))"
' "$PLAN_JSON")

if [[ -n "$DANGEROUS" ]]; then
  echo "::error::Plan contains destructive changes to existing Lighthouse resources:"
  echo "$DANGEROUS"
  echo "::error::This can sever an active managed-services delegation. Requires the 'lighthouse-destructive-override' PR label to proceed."
  exit 1
fi

echo "No destructive changes to existing Lighthouse resources detected."
