output "lighthouse_definition_id" {
  description = "Resource ID of the created Lighthouse registration definition."
  value       = module.lighthouse_delegation.definition_id
}

output "lighthouse_assignment_id" {
  description = "Resource ID of the created Lighthouse registration assignment."
  value       = module.lighthouse_delegation.assignment_id
}
