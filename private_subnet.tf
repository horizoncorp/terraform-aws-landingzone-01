locals {
  private_subnets = flatten([
    for subnet_key, subnet_value in var.subnet : [
      for cidr in subnet_value.private_cidr : {
        subnet_key = subnet_key
        cidr       = cidr
        az         = subnet_value.az
      }
    ]
  ])
}

resource "aws_subnet" "private_subnet" {
  for_each = {
    for subnet in local.private_subnets : "${subnet.subnet_key}.${subnet.cidr}" => subnet
  }
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "private_rtb_subnet_association" {
  for_each = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = values({for k, v in aws_subnet.private_subnet : k => v.id})
}
