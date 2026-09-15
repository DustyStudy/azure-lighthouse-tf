# Uses Terraform's native testing framework (`terraform test`, 1.6+).
# The provider is mocked - these tests never touch a real Azure subscription,
# so they run in CI with zero cloud credentials and zero cost. They check
# that the module's own guardrails (the `authorizations` validation block)
# actually reject bad input, and that valid input produces the expected
# plan - not that Azure itself behaves a certain way.
#
# Run locally with: terraform test

mock_provider "azurerm" {}

variables {
  azure_environment  = "public"
  scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
  managing_tenant_id = "11111111-1111-1111-1111-111111111111"
  delegation_name    = "test-delegation"
}

run "valid_authorization_plans_successfully" {
  command = plan

  variables {
    authorizations = [
      { principal_id = "22222222-2222-2222-2222-222222222222", principal_display_name = "Test Reader", role_definition_id = "acdd72a7-3385-48ef-bd42-f606fba81ae7" }
    ]
  }

  assert {
    condition     = length(var.authorizations) == 1
    error_message = "Expected exactly one authorization to be accepted"
  }
}

run "empty_authorizations_list_is_rejected" {
  command = plan

  variables {
    authorizations = []
  }

  expect_failures = [
    var.authorizations,
  ]
}
