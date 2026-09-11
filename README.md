# azure-lighthouse-tf

Terraform automation for Azure Lighthouse delegated resource management,
deployable to both **Azure Public** and **Azure Government**, with GitHub
Actions CI/CD and pre-deployment validation designed for a control that
grants cross-tenant access.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design
rationale.

## Layout

```
modules/lighthouse-delegation/   # the actual Lighthouse definition + assignment
environments/{public,gov}/       # per-cloud tfvars (scope, tenant, authorizations)
backend-config/{public,gov}.hcl  # per-cloud remote state config
scripts/prechecks/               # validation run in CI before any apply
.github/workflows/               # precheck (PR) + deploy (main, per-cloud)
```

## One-time setup before first use

1. Create the two Terraform state storage accounts referenced in
   `backend-config/public.backend.hcl` and `backend-config/gov.backend.hcl`,
   and update the storage account names there (they must be globally unique).
2. Create one App Registration per cloud, each with an OIDC federated
   credential scoped to its GitHub Environment subject
   (`repo:DustyStudy/azure-lighthouse-tf:environment:public-prod` /
   `...:environment:gov-prod`).
3. Create the `public-prod` and `gov-prod` GitHub Environments with required
   reviewers, and set these repository/environment **variables** (not
   secrets - none of these values are sensitive) per cloud:
   `AZURE_CLIENT_ID_public`, `AZURE_TENANT_ID_public`,
   `AZURE_SUBSCRIPTION_ID_public`, and the `_gov` equivalents.
4. Fill in the real `scope`, `managing_tenant_id`, and `authorizations` in
   `environments/public/terraform.tfvars` and `environments/gov/terraform.tfvars`.
5. In repo Settings → Branches, mark the `Precheck` job's checks as required
   on `main`.

## Usage

Open a PR touching `environments/<cloud>/terraform.tfvars` (or the module).
The precheck workflow lints, validates principals/roles, and posts a plan.
On merge to `main`, the matching `deploy-*.yml` workflow applies it after
environment-level reviewer approval.
