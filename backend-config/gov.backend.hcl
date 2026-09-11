# terraform init -backend-config=backend-config/gov.backend.hcl
#
# This storage account MUST live in Azure Government - a commercial storage
# account is not reachable from usgovernment ARM endpoints and vice versa.
# Auth is via OIDC, same as public.backend.hcl - no access keys.

resource_group_name  = "rg-tfstate-lighthouse-gov"
storage_account_name = "sttfstatelighthousegov"   # must be globally unique within Gov cloud - update before first use
container_name       = "tfstate"
key                  = "azure-lighthouse-tf/gov/terraform.tfstate"
use_azuread_auth     = true
use_oidc             = true
