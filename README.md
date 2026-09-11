# azure-lighthouse-tf

[![Precheck](https://github.com/DustyStudy/azure-lighthouse-tf/actions/workflows/precheck.yml/badge.svg)](https://github.com/DustyStudy/azure-lighthouse-tf/actions/workflows/precheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Terraform automation for [Azure Lighthouse](https://learn.microsoft.com/en-us/azure/lighthouse/) delegated resource management, deployable to
both **Azure Public** and **Azure Government** from a single codebase, with
GitHub Actions CI/CD and pre-deployment validation built for a control that
grants cross-tenant access.

**This is a template repo**, not a live deployment - fork or use as a
template, then follow "Adopting this template" below to point it at a real
subscription. Nobody needs to authenticate to Azure to read, fork, or review
it; see [`SECURITY.md`](SECURITY.md) for the security model this repo
follows.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design
rationale.

## Highlights

- **Keyless auth** - OIDC federated credentials only; no client secrets or
  long-lived keys anywhere in the pipeline.
- **Dual-cloud from one codebase** - the same Terraform module deploys to
  Azure Public and Azure Government via separate tfvars, backends, and OIDC
  credentials, never sharing state or trust between the two.
- **SHA-pinned Actions**, kept current via Dependabot rather than hand-edited
  hashes, to close the exact class of supply-chain attack a mutable tag
  reference is vulnerable to.
- **Custom policy gates** beyond generic linting: reject unreviewed
  high-privilege role delegations, and block any plan that would silently
  delete or replace an existing cross-tenant access grant.
- **Template-safe CI** - code-quality checks (`fmt`, `validate`, `tflint`,
  `checkov`) run and enforce on every PR with zero Azure setup; the
  Azure-dependent jobs skip cleanly until a real subscription is wired up.

## Layout

```
modules/lighthouse-delegation/   # the actual Lighthouse definition + assignment
environments/{public,gov}/       # per-cloud tfvars (scope, tenant, authorizations) - placeholder GUIDs, fill in your own
backend-config/{public,gov}.hcl  # per-cloud remote state config
scripts/prechecks/                # validation run in CI before any apply
.github/workflows/                # precheck (PR) + deploy (main, per-cloud)
```

## Works out of the box, with no Azure setup

On a fresh fork/clone with none of the variables below set, the `Precheck`
workflow still runs and still enforces real quality gates:
`terraform fmt`, `terraform validate`, `tflint`, and a `checkov` security
scan all run on every PR with no Azure credentials required. The
Azure-dependent jobs (principal-ID validation, `terraform plan`,
`terraform apply`) detect that no subscription is configured and skip
cleanly instead of failing - so this template is safe to explore, fork, and
send PRs against before anyone has connected it to a real subscription.

## Adopting this template (per team / per subscription)

Whoever wants this to actually deploy something does the following, once,
against their own org:

1. Create the two Terraform state storage accounts referenced in
   `backend-config/public.backend.hcl` and `backend-config/gov.backend.hcl`,
   and update the storage account names there (they must be globally unique).
2. Create one App Registration per cloud in **your own tenant**, each with
   two OIDC federated credentials:
   - one scoped to `repo:<owner>/<repo>:pull_request` (used by the read-only
     PR precheck job)
   - one scoped to `repo:<owner>/<repo>:environment:public-prod` (or
     `...:environment:gov-prod`) for the actual deploy job
3. Create the `public-prod` and `gov-prod` GitHub Environments in your fork,
   with required reviewers, and set these repository **variables** (not
   secrets - none of these values are sensitive) per cloud:
   `AZURE_CLIENT_ID_public`, `AZURE_TENANT_ID_public`,
   `AZURE_SUBSCRIPTION_ID_public`, and the `_gov` equivalents. Once these
   exist, the Azure-dependent jobs stop skipping and start actually running.
4. Replace the placeholder GUIDs with the real `scope`, `managing_tenant_id`,
   and `authorizations` in `environments/public/terraform.tfvars` and
   `environments/gov/terraform.tfvars`.
5. In repo Settings → Branches, mark the `static-analysis` job as a required
   status check on `main` (this is the one that always runs). Add the
   Azure-dependent jobs as required too once step 3 is done and they're
   reliably running rather than skipping.

## Usage (once adopted)

Open a PR touching `environments/<cloud>/terraform.tfvars` (or the module).
The precheck workflow lints, validates principals/roles, and posts a plan.
On merge to `main`, the matching `deploy-*.yml` workflow applies it after
environment-level reviewer approval.

