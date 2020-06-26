# -------------------------------------------------------------------------------------------------
# Default settings
# -------------------------------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC id in which the security groups will be created"
  type = string
  default = ""
}

# Example tags definition:
#
# tags = {
#   "PRODUCT" = "security groups",
#   "SITE" = "example.com",
#   "PROJECT" = "my project",
# }

variable "tags" {
  description = "Tags list"
  type = map
  default = {}
}

# -------------------------------------------------------------------------------------------------
# Security Groups definition
# -------------------------------------------------------------------------------------------------

# Example security groups definition:
#
# security_groups = [
#   {
#       "name" = "fwrule1",
#       "description" = "fwrule1 description here"
#       "inbound" = [
#           {
#               "ports" = "80"
#               "protocol" = "tcp"
#               "cidr_blocks" = ["10.20.0.0/24"]
#           },
#           {
#               "protocol" = "tcp"
#               "ports" = "443-500"
#               "cidr_blocks" = ["10.20.0.0/24"]
#           },
#       ],
#       "outbound" = [
#           {
#               "ports" = "0"
#               "protocol" = "all"
#               "cidr_blocks" = ["0.0.0.0/0"]
#           },
#       ],
#   },
#   {
#       "name" = "fwrule2",
#       "description" = "fwrule2 description here"
#       "inbound" = [
#           {
#               "ports" = "8443-8500"
#               "protocol" = "tcp"
#               "cidr_blocks" = ["10.21.0.0/24"]
#           },
#       ],
#       "outbound" = [
#           {
#               "ports" = "0"
#               "protocol" = "all"
#               "cidr_blocks" = ["0.0.0.0/0"]
#           },
#       ],
#   },
# ]

variable "security_groups" {
  description = "A list of dictionaries defining all security groups."
  type = list(object({
    name = string                 # Name of the security groups
    description = string          # Description of the security groups
    inbound = list(object({
      ports = string              # Range of inbound ports. Can be single string or range of ports for eg: "80", "1000-1050" etc
      protocol = string           # Protocol. Refer to AWS security groups settings for list of protocol
      cidr_blocks = list(string)  # Subnet address for the inbound rules
    }))
    outbound = list(object({
      ports = string              # Range of outbound ports. Can be single string or range of ports for eg: "80", "1000-1050" etc
      protocol = string           # Protocol. Refer to AWS security groups settings for list of protocol
      cidr_blocks = list(string)  # Subnet address for the inbound rules
    }))
  }))
  default = []
}