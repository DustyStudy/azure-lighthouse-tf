## What this changes

<!-- Brief description of the change and why. -->

## Checklist

- [ ] `terraform fmt -recursive` run locally
- [ ] `terraform validate` passes locally
- [ ] If this touches `environments/*/terraform.tfvars`: principal IDs and
      role definitions are correct for the target tenant
- [ ] If this could delete or replace an existing Lighthouse definition or
      assignment: I understand the `plan` job will block this unless the
      PR carries the `lighthouse-destructive-override` label, and I've
      requested an extra reviewer if that label is needed

## Risk

<!-- Does this change what access an external tenant has? Low/Medium/High and why. -->
