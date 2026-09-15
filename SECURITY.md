# Security

## Design principles this repo follows

- **No standing cloud credentials.** All authentication to Azure is via
  OIDC federated credentials exchanged for a short-lived token at
  workflow-run time - there is no client secret or long-lived key stored
  anywhere in this repo or its CI configuration.
- **Third-party GitHub Actions are pinned to a full commit SHA**, not a
  mutable tag, specifically to prevent the class of supply-chain attack
  where a compromised or force-pushed tag silently changes the code a
  workflow executes (see `.github/dependabot.yml`, which keeps those pins
  current via verified PRs rather than hand-edited hashes).
- **Every change to infrastructure that grants cross-tenant access goes
  through a required PR**, gated on `terraform fmt`, `terraform validate`,
  `tflint`, and a `checkov` static security scan, plus custom checks that
  reject unreviewed high-privilege role delegations (Owner, User Access
  Administrator) and block any plan that would silently delete or replace
  an existing access grant.
- **Deploys require environment-level human approval** (GitHub
  Environments with required reviewers), scoped per cloud, so a compromise
  of one cloud's credentials can't be used to authenticate against the
  other.

## Reporting a vulnerability

If you find a security issue in this repo's Terraform, workflows, or
scripts, please open a GitHub issue or reach out directly rather than
filing a public PR that reproduces the problem. This is a personal/portfolio
repository, not a supported product, so there's no formal SLA, but reports
are genuinely welcome.
