# vpc cidr
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# vpc_name
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

# private_subnet_data
variable "private_subnet_data" {
  description = "List of maps containing private subnet data"
  type = list(object({
    cidr              = string
    availability_zone = string
    prefix            = string
  }))
}

# public_subnet_data
variable "public_subnet_data" {
  description = "List of maps containing public subnet data"
  type = list(object({
    cidr              = string
    availability_zone = string
    prefix            = string
  }))
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false

}