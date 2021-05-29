output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value = {
    for k, v in aws_subnet.public_subnet : k => v.id
  }
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value = {
    for k, v in aws_subnet.private_subnet : k => v.id
  }
}

output "public_rtb" {
  description = "Routetable ID associated with public subnets"
  value       = aws_route_table.public_rtb.id
}

output "private_rtb" {
  description = "Routetable ID associated with private subnets"
  value       = aws_route_table.private_rtb.id
}

output "public_nacl" {
  description = "NACL ID associated with public subnets"
  value       = aws_network_acl.public_nacl.id
}

output "private_nacl" {
  description = "NACL ID associated with private subnets"
  value       = aws_network_acl.private_nacl.id
}
