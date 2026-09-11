# lighthouse-delegation

Creates an `azurerm_lighthouse_definition` (the registration definition the
customer tenant admin approves) plus its matching
`azurerm_lighthouse_assignment` at a given scope.

## Notes

- `scope` can be a subscription (`/subscriptions/<id>`) or a management group
  (`/providers/Microsoft.Management/managementGroups/<id>`). Management-group
  scope is generally preferable when onboarding many subscriptions at once,
  since it avoids one Lighthouse definition per subscription.
- `role_definition_id` in each authorization is the **role GUID only**
  (e.g. `b24988ac-6180-42a0-ab88-20f7382dd24c` for Contributor), not the full
  `/providers/Microsoft.Authorization/roleDefinitions/...` resource ID.
  Terraform / the AzureRM provider expects the bare GUID here.
- This module does not itself restrict which roles can be used — that
  enforcement lives in `scripts/prechecks/validate-role-defs.sh`, which runs
  against the plan before apply. Keep it that way: policy belongs in the
  precheck, not baked into the module, so the same module can be reused for
  both a tightly-scoped customer delegation and a broader internal one under
  different precheck configs.
