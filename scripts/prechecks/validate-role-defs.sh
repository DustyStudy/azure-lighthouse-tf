#!/usr/bin/env bash
# Fails the build if a role_definition_id in the target tfvars matches a
# built-in high-privilege role that is not explicitly allow-listed.
#
# Usage: validate-role-defs.sh <tfvars-file> [allowlist-file]
#
# allowlist-file (optional): one role-definition GUID per line that is
# permitted despite being high-privilege. Defaults to no exceptions.

set -euo pipefail

TFVARS_FILE="${1:?Usage: validate-role-defs.sh <tfvars-file> [allowlist-file]}"
ALLOWLIST_FILE="${2:-}"

# Built-in role GUIDs that grant broad control-plane or access-control power.
# Extend this list deliberately - it is meant to be short and high-signal.
declare -A DENIED_ROLES=(
  ["8e3af657-a8ff-443c-a75c-2fe8c4bcb635"]="Owner"
  ["18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"]="User Access Administrator"
  ["f58310d9-a9f6-439a-9e8d-f62e7b41a168"]="Role Based Access Control Administrator"
)

ALLOWED=()
if [[ -n "$ALLOWLIST_FILE" && -f "$ALLOWLIST_FILE" ]]; then
  mapfile -t ALLOWED < <(grep -vE '^\s*#|^\s*$' "$ALLOWLIST_FILE")
fi

is_allowed() {
  local guid="$1"
  for a in "${ALLOWED[@]:-}"; do
    [[ "$guid" == "$a" ]] && return 0
  done
  return 1
}

mapfile -t ROLE_IDS < <(grep -oE 'role_definition_id[[:space:]]*=[[:space:]]*"[0-9a-fA-F-]{36}"' "$TFVARS_FILE" \
  | grep -oE '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' \
  | sort -u)

FAILED=0
for rid in "${ROLE_IDS[@]}"; do
  name="${DENIED_ROLES[$rid]:-}"
  if [[ -n "$name" ]]; then
    if is_allowed "$rid"; then
      echo "::warning::role $name ($rid) is high-privilege but present in the allowlist - proceeding."
    else
      echo "::error::role $name ($rid) is high-privilege and NOT allow-listed. Add it to the allowlist file with justification if this is intentional, or use a narrower role."
      FAILED=1
    fi
  fi
done

if [[ "$FAILED" -eq 1 ]]; then
  exit 1
fi

echo "No disallowed role definitions found."
