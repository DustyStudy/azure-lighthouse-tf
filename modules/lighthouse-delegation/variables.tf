variable "scope" {
  description = "Resource ID of the subscription or management group being delegated."
  type        = string
}

variable "managing_tenant_id" {
  description = "Tenant ID of the managing tenant receiving delegated access."
  type        = string
}

variable "delegation_name" {
  description = "Display name for the registration definition."
  type        = string
}

variable "delegation_description" {
  description = "Description shown to the customer tenant admin."
  type        = string
  default     = ""
}

variable "authorizations" {
  description = "List of principal/role delegations. See root variables.tf for the full contract."
  type        = list(object({
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
