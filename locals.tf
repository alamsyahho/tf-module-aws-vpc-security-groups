# -------------------------------------------------------------------------------------------------
# Tags transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local will combine security groups name into var.tags
  #
  #  tags = {
  #      "<tag-key-1>" = "<tag-value-1>",
  #      "<tag-key-2>" = "<tag-value-2>",
  #      "<tag-key-3>" = "<tag-value-3>",
  #    }
  #  }
  #
  # security_groups = [
  #   {
  #     "name" = "<security-groups-1>",
  #     ...
  #   },
  #   {
  #     "name" = "<security-groups-2>",
  #     ...
  #   },
  # ]
  #
  # Into the following format:
  #
  # local_tags = {
  #   "<security-groups-1>" = {
  #     "Name" = "<security-groups-1>"
  #     "<tag-key-1>" = "<tag-value-1>",
  #     "<tag-key-2>" = "<tag-value-2>",
  #     "<tag-key-3>" = "<tag-value-3>",
  #   }
  #   "<security-groups-2>" = {
  #     "Name" = "<security-groups-2>"
  #     "<tag-key-1>" = "<tag-value-1>",
  #     "<tag-key-2>" = "<tag-value-2>",
  #     "<tag-key-3>" = "<tag-value-3>",
  #   }
  # }
  tags = { for i, v in var.security_groups : var.security_groups[i]["name"] => merge(
      { "Name" = var.security_groups[i]["name"] },
      var.tags
    )
  }
}

# -------------------------------------------------------------------------------------------------
# Security groups transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local will combine var.security_groups with local.tags and tranform it from:
  #
  # security_groups = [
  #   {
  #     "name" = "<security-groups-name>"
  #     "description" = "<security-groups-description>"
  #     ...
  #   },
  #   {
  #     "name" = "<security-groups-name>"
  #     "description" = "<security-groups-description>"
  #     ...
  #   },
  # ]
  #
  # local_tags = {
  #   "<security-groups-name>" = {
  #     "Name" = "<security-groups-name>"
  #     "<tag-key-1>" = "<tag-value-1>",
  #     "<tag-key-2>" = "<tag-value-2>",
  #     "<tag-key-3>" = "<tag-value-3>",
  #   }
  #   "<security-groups-name>" = {
  #     "Name" = "<security-groups-name>"
  #     "<tag-key-1>" = "<tag-value-1>",
  #     "<tag-key-2>" = "<tag-value-2>",
  #     "<tag-key-3>" = "<tag-value-3>",
  #   }
  # }
  #
  # Into the following format:
  #
  # security_groups = {
  #   "<security-groups-name>" = {
  #     "name" = "<security-groups-name>"
  #     "description" = "<security-groups-description>"
  #     "tags" = {
  #       "Name" = "<security-groups-name>"
  #       "<tag-key-1>" = "<tag-value-1>",
  #       "<tag-key-2>" = "<tag-value-2>",
  #       "<tag-key-3>" = "<tag-value-3>",
  #     }
  #     ...
  #   }
  #   "<security-groups-name>" = {
  #     "description" = "<security-groups-description>"
  #     "name" = "<security-groups-name>"
  #     "tags" = {
  #       "Name" = "<security-groups-name>"
  #       "<tag-key-1>" = "<tag-value-1>",
  #       "<tag-key-2>" = "<tag-value-2>",
  #       "<tag-key-3>" = "<tag-value-3>",
  #     }
  #     ...
  #   }
  # }

  security_groups = { for i, v in var.security_groups : var.security_groups[i]["name"] => merge(
        v,
        { "tags" = local.tags[var.security_groups[i]["name"]] } )
  }
}

# -------------------------------------------------------------------------------------------------
# Inbound rules transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local will extract the inbound rules from var.security_groups and it will also create additional key "from_port" and "to_port" based on the value of inbound "ports". So it will transform from:
  #
  # security_groups = [
  #   {
  #     "name" = "<security-groups-name>"
  #     "inbound" = [
  #       {
  #         "cidr_blocks" = ["10.20.0.0/24",]
  #         "ports" = "80"
  #         "protocol" = "tcp"
  #       },
  #       {
  #         "cidr_blocks" = ["10.20.0.0/24",]
  #         "ports" = "443-500"
  #         "protocol" = "tcp"
  #       },
  #     ]
  #     ...
  #   },
  #   {
  #     "name" = "<security-groups-name>"
  #     "inbound" = [
  #       {
  #         "cidr_blocks" = ["10.21.0.0/24",]
  #         "ports" = "8080"
  #         "protocol" = "tcp"
  #       },
  #       {
  #         "cidr_blocks" = ["10.21.0.0/24",]
  #         "ports" = "8443-8500"
  #         "protocol" = "tcp"
  #       },
  #     ]
  #     ...
  #   },
  # ]
  #
  # Into the following format:
  #
  # inbound = {
  #   "<security-groups-name>:inbound_rule_0" = {
  #     "cidr_blocks" = ["10.20.0.0/24",]
  #     "from_port" = "80"
  #     "ports" = "80"
  #     "protocol" = "tcp"
  #     "to_port" = "80"
  #   }
  #   "<security-groups-name>:inbound_rule_1" = {
  #     "cidr_blocks" = ["10.20.0.0/24",]
  #     "from_port" = "443"
  #     "ports" = "443-500"
  #     "protocol" = "tcp"
  #     "to_port" = "500"
  #   }
  #   "<security-groups-name>:inbound_rule_0" = {
  #     "cidr_blocks" = ["10.21.0.0/24",]
  #     "from_port" = "8080"
  #     "ports" = "8080"
  #     "protocol" = "tcp"
  #     "to_port" = "8080"
  #   }
  #   "<security-groups-name>:inbound_rule_1" = {
  #     "cidr_blocks" = ["10.21.0.0/24",]
  #     "from_port" = "8443"
  #     "ports" = "8443-8500"
  #     "protocol" = "tcp"
  #     "to_port" = "8500"
  #   }
  # }

  ir = flatten([
    for group in var.security_groups : [
      for i, rule in group["inbound"] : {
        sg_name   = group.name
        rule_name = join("_", ["inbound_rule", i])
        inbound_rule = merge(
          rule,
          length(
            split("-", rule.ports)) == 2
            ? zipmap(
                ["from_port", "to_port"],
                length(regexall("^-", rule.ports)) == 1 ? [rule.ports, rule.ports] : split("-", rule.ports))
              )
            : {"from_port": rule.ports, "to_port":rule.ports}
          )
      }
    ]
  ])

  inbound_rules = { for obj in local.ir : "${obj.sg_name}:${obj.rule_name}" => obj.inbound_rule }
}

# -------------------------------------------------------------------------------------------------
# Outbound rules transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local will extract the outbound rules from var.security_groups and it will also create additional key "from_port" and "to_port" based on the value of inbound "ports". So it will transform from:
  #security_groups = [
  #   {
  #     "name" = "<security-groups-name>"
  #     ...
  #     "outbound" = [
  #       {
  #         "cidr_blocks" = ["0.0.0.0/0",]
  #         "ports" = "0"
  #         "protocol" = "all"
  #       },
  #     ]
  #   },
  #   {
  #     "name" = "<security-groups-name>"
  #     ...
  #     "outbound" = [
  #       {
  #         "cidr_blocks" = ["0.0.0.0/0",]
  #         "ports" = "0"
  #         "protocol" = "all"
  #       },
  #     ]
  #   },
  # ]
  #
  # Into the following format:
  #
  # outbound = {
  #   "<security-groups-name>:outbound_rule_0" = {
  #     "cidr_blocks" = ["0.0.0.0/0",]
  #     "from_port" = "0"
  #     "ports" = "0"
  #     "protocol" = "all"
  #     "to_port" = "0"
  #   }
  #   "<security-groups-name>:outbound_rule_0" = {
  #     "cidr_blocks" = ["0.0.0.0/0",]
  #     "from_port" = "0"
  #     "ports" = "0"
  #     "protocol" = "all"
  #     "to_port" = "0"
  #   }
  # }

  or = flatten([
    for group in var.security_groups : [
      for i, rule in group["outbound"] : {
        sg_name   = group.name
        rule_name = join("_", ["outbound_rule", i])
        outbound_rule = merge(rule, length(split("-", rule.ports)) == 2 ? zipmap(["from_port", "to_port"], split("-", rule.ports)) : {"from_port": rule.ports, "to_port":rule.ports})
      }
    ]
  ])

  outbound_rules = { for obj in local.or : "${obj.sg_name}:${obj.rule_name}" => obj.outbound_rule }
}