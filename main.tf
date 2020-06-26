# -------------------------------------------------------------------------------------------------
# Set module requirements
# -------------------------------------------------------------------------------------------------
terraform {
  # >= v0.12.6
  required_version = ">= 0.12.6"
}

# -------------------------------------------------------------------------------------------------
# Create managed security groups
# -------------------------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  for_each = local.security_groups

  name        = lookup(each.value, "name")
  description = lookup(each.value, "description")
  vpc_id      = var.vpc_id

  tags = lookup(each.value, "tags")
}


# -------------------------------------------------------------------------------------------------
# Create managed inbound rules
# -------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "this_inbound" {
  for_each          = local.inbound_rules

  type              = "ingress"
  from_port         = lookup(each.value, "from_port")
  to_port           = lookup(each.value, "to_port")
  protocol          = lookup(each.value, "protocol")
  cidr_blocks       = lookup(each.value, "cidr_blocks")
  security_group_id = aws_security_group.this[split(":", each.key)[0]].id
}

# -------------------------------------------------------------------------------------------------
# Create managed outbound rules
# -------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "this_outbound" {
  for_each          = local.outbound_rules

  type              = "egress"
  from_port         = lookup(each.value, "from_port")
  to_port           = lookup(each.value, "to_port")
  protocol          = lookup(each.value, "protocol")
  cidr_blocks       = lookup(each.value, "cidr_blocks")
  security_group_id = aws_security_group.this[split(":", each.key)[0]].id
}