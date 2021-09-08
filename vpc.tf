locals {
  ibm_traffic_gateway_connection_count = var.ibm_transit_gateway_id == "" ? 0 : 1
}

resource "ibm_is_vpc" "vpc" {
  name                      = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
  resource_group            = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "vpc_address_prefix" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-ap"
  zone = "${var.ibm_region}-${var.ibm_zone}"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ibm_vpc_cidr
}

// allow all inbound
resource "ibm_is_security_group_rule" "allow_inbound" {
  depends_on = [ibm_is_vpc.vpc]
  group      = ibm_is_vpc.vpc.default_security_group
  direction  = "inbound"
  remote     = "0.0.0.0/0"
}

// all all outbound
resource "ibm_is_security_group_rule" "allow_outbound" {
  depends_on = [ibm_is_vpc.vpc]
  group      = ibm_is_vpc.vpc.default_security_group
  direction  = "outbound"
  remote     = "0.0.0.0/0"
}

resource "ibm_is_subnet" "internal" {
  name            = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-internal"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-${var.ibm_zone}"
  resource_group  = data.ibm_resource_group.group.id
  depends_on      = [ibm_is_vpc_address_prefix.vpc_address_prefix]
  ipv4_cidr_block = cidrsubnet(var.ibm_vpc_cidr, 4, 1)
}

resource "ibm_is_public_gateway" "external_gateway" {
  name = "${var.ibm_vpc_name}-external-gateway"
  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.ibm_region}-${var.ibm_zone}"
}

resource "ibm_is_subnet" "external" {
  name            = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-external"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-${var.ibm_zone}"
  resource_group  = data.ibm_resource_group.group.id
  depends_on      = [ibm_is_vpc_address_prefix.vpc_address_prefix]
  ipv4_cidr_block = cidrsubnet(var.ibm_vpc_cidr, 4, 2)
  public_gateway  = ibm_is_public_gateway.external_gateway.id
}

data "ibm_is_ssh_key" "ssh_key" {
  name = var.ibm_ssh_key_name
}

resource "ibm_tg_connection" "ibm_tg_connect" {
  count        = local.ibm_traffic_gateway_connection_count
  gateway      = var.ibm_transit_gateway_id
  network_type = "vpc"
  name         = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-connection"
  network_id   = ibm_is_vpc.vpc.resource_crn
  depends_on   = [ibm_is_security_group_rule.allow_outbound, ibm_is_subnet.internal, ibm_is_subnet.external]
}
