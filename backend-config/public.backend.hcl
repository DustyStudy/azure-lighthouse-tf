# terraform init -backend-config=backend-config/public.backend.hcl
#
# Auth to this storage account is via OIDC (use_oidc / use_azuread_auth),
# never a storage account access key. The workflow sets ARM_* and
# ARM_USE_OIDC=true env vars; nothing secret lives in this file.

resource_group_name  = "rg-tfstate-lighthouse-public"
storage_account_name = "sttfstatelighthousepub"   # must be globally unique - update before first use
container_name       = "tfstate"
key                  = "azure-lighthouse-tf/public/terraform.tfstate"
use_azuread_auth     = true
use_oidc             = true
