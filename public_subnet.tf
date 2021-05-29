locals {
  public_subnets = flatten([
    for subnet_key, subnet_value in var.subnet : [
      for cidr in subnet_value.public_cidr : {
        subnet_key = subnet_key
        cidr       = cidr
        az         = subnet_value.az
      }
    ]
  ])
}

resource "aws_subnet" "public_subnet" {
  for_each = {
    for subnet in local.public_subnets : "${subnet.subnet_key}.${subnet.cidr}" => subnet
  }
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.az
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rtb_subnet_association" {
  for_each = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = values({for k, v in aws_subnet.public_subnet : k => v.id})
}

resource "aws_network_acl_rule" "egress" {
    network_acl_id = aws_network_acl.public_nacl.id
    rule_number    = 100
    egress         = true
    protocol       = "all"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "ingress" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}