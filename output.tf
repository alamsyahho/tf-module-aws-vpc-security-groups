# -------------------------------------------------------------------------------------------------
# Input variables
# -------------------------------------------------------------------------------------------------

output "var_vpc_id" {
  description = "The defined vpc id"
  value       = var.vpc_id
}

output "var_tags" {
  description = "The defined tags map"
  value       = var.tags
}

output "var_security_groups" {
  description = "The defined security_groups list"
  value       = var.security_groups
}

# -------------------------------------------------------------------------------------------------
# Transformed variables
# -------------------------------------------------------------------------------------------------

output "local_tags" {
  description = "The transformed tags map"
  value       = local.tags
}

output "local_security_groups" {
  description = "The transformed security_groups map"
  value       = local.security_groups
}

output "local_inbound_rules" {
  description = "The transformed inbound_rules map"
  value       = local.inbound_rules
}

output "local_outbound_rules" {
  description = "The transformed outbound_rules map"
  value       = local.outbound_rules
}

# -------------------------------------------------------------------------------------------------
# Created resources
# -------------------------------------------------------------------------------------------------

output "created_security_groups" {
  description = "Created Security Groups"
  value       = aws_security_group.this
}

output "created_inbound_rules" {
  description = "Created Inbound Rules"
  value       = aws_security_group_rule.this_inbound
}

output "created_outbound_rules" {
  description = "Created Outbound Rules"
  value       = aws_security_group_rule.this_outbound
}