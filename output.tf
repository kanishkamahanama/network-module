# VPC name passed in via variable
output "vpc_name" {
  value = var.vpc_name
}

# Created VPC resource ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Public subnet IDs from the public subnet map/list
output "pulic_subnet_ids" {
  value = aws_subnet.public[*].id
}

# Private subnet IDs from the private subnet map/list
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}