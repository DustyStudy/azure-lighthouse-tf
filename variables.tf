variable "azure_environment" {
  description = "Which Azure cloud to target. Must be \"public\" or \"usgovernment\"."
  type        = string

  validation {
    condition     = contains(["public", "usgovernment"], var.azure_environment)
    error_message = "azure_environment must be exactly \"public\" or \"usgovernment\"."
  }
}

variable "scope" {
  description = "Resource ID of the subscription (or management group) being delegated, e.g. /subscriptions/<id> or /providers/Microsoft.Management/managementGroups/<id>."
  type        = string
}

variable "managing_tenant_id" {
  description = "Tenant ID of the managing (service provider) tenant that will receive delegated access."
  type        = string
}

variable "delegation_name" {
  description = "Display name for the Lighthouse registration definition."
  type        = string
}

variable "delegation_description" {
  description = "Human-readable description shown to the customer tenant admin."
  type        = string
  default     = ""
}

variable "authorizations" {
  description = <<-EOT
    List of role delegations to grant the managing tenant. Each entry:
      principal_id                  = object ID of the user/group/SPN in the MANAGING tenant
      principal_display_name        = friendly name shown in the customer's Lighthouse UI
      role_definition_id            = built-in role definition GUID (NOT the full resource ID)
      delegated_role_definition_ids = optional list of role GUIDs this principal
                                       may further delegate via PIM eligible assignments
    Deliberately does NOT default to any value — every deployment must state
    its own authorizations explicitly. The precheck job rejects Owner
    (8e3af657-a8ff-443c-a75c-2fe8c4bcb635) and User Access Administrator
    (18d7d88d-d35e-4fb5-a5c3-7773c20a72d9) unless allow-listed.
  EOT
  type = list(object({
    principal_id                  = string
    principal_display_name        = string
    role_definition_id            = string
    delegated_role_definition_ids = optional(list(string), [])
  }))

  validation {
    condition     = length(var.authorizations) > 0
    error_message = "At least one authorization is required; an empty delegation grants no access and is almost certainly a mistake."
  }
}

