output "vpc_id" {
  value = ibm_is_vpc.vpc.id
}

output "vpc_default_security_group_id" {
  value = ibm_is_vpc.vpc.default_security_group
}

output "vpc_external_subnet_id" {
  value = ibm_is_subnet.external.id
}

output "vpc_external_subnet_cidr" {
  value = ibm_is_subnet.external.ipv4_cidr_block
}

output "vpc_internal_subnet_id" {
  value = ibm_is_subnet.internal.id
}

output "vpc_internal_subnet_cidr" {
  value = ibm_is_subnet.internal.ipv4_cidr_block
}

output "vpc_inside_gateway" {
  value = cidrhost(ibm_is_subnet.internal.ipv4_cidr_block, 1)
}