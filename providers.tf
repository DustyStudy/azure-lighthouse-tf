terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Backend is intentionally left partial. It is completed at `terraform init`
  # time via -backend-config=backend-config/public.backend.hcl (or gov.backend.hcl).
  # This is what lets the SAME root module deploy to either cloud without
  # ever hardcoding a storage account that lives in the other cloud.
  backend "azurerm" {}
}

# `azure_environment` must be "public" or "usgovernment". It drives both the
# ARM endpoint the provider talks to and (indirectly, via backend-config)
# which state storage account is used. Passed via -var or a tfvars file,
# never hardcoded here, so the same config works for both clouds.
provider "azurerm" {
  environment = var.azure_environment
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  # Auth is exclusively via OIDC federated credentials injected as
  # ARM_CLIENT_ID / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID / ARM_USE_OIDC=true
  # environment variables by the GitHub Actions workflow. No client secret
  # is ever read by this provider block.
}
