
module "consul_cluster_vsis" {
  source                = "./modules/consul_vsis"
  count                 = var.consul_include ? 1 : 0
  consul_cluster_size   = var.consul_cluster_size
  ibm_resource_group    = var.ibm_resource_group
  ibm_region            = var.ibm_region
  ibm_zone              = ibm_is_subnet.internal.zone
  ibm_profile           = var.consul_instance_profile
  ibm_ssh_key_name      = var.ibm_ssh_key_name
  ibm_security_group_id = ibm_is_vpc.vpc.default_security_group
  ibm_subnet_id         = ibm_is_subnet.internal.id
  consul_organization   = var.volterra_tenant
  consul_datacenter     = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}"
  consul_client_token   = var.consul_client_token
}

module "volterra_cluster" {
  source                        = "./modules/volterra"
  count                         = var.volterra_include_ce ? 1 : 0
  volterra_cluster_size         = var.volterra_cluster_size
  ibm_resource_group            = var.ibm_resource_group
  ibm_region                    = var.ibm_region
  ibm_zone                      = ibm_is_subnet.internal.zone
  ibm_profile                   = var.volterra_ce_profile
  ibm_ssh_key_name              = var.ibm_ssh_key_name
  ibm_outside_subnet_id         = ibm_is_subnet.external.id
  ibm_outside_security_group_id = ibm_is_vpc.vpc.default_security_group
  ibm_inside_subnet_id          = ibm_is_subnet.internal.id
  ibm_inside_security_group_id  = ibm_is_vpc.vpc.default_security_group
  ibm_inside_gateway            = cidrhost(ibm_is_subnet.internal.ipv4_cidr_block, 1)
  ibm_inside_networks           = var.ibm_internal_networks
  volterra_download_region      = var.ibm_download_region
  volterra_ce_version           = var.volterra_ce_version
  volterra_tenant_name          = var.volterra_tenant_name
  volterra_site_name            = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}"
  volterra_fleet_label          = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_zone}-${var.ibm_vpc_index}-fleet"
  volterra_api_token            = var.volterra_api_token
  volterra_admin_password       = var.volterra_admin_password
  volterra_ipsec_tunnels        = var.volterra_ipsec_tunnels
  volterra_ssl_tunnels          = var.volterra_ssl_tunnels
  consul_ca_cert                = join("", module.consul_cluster_vsis.*.datacenter_ca_certificate)
  consul_https_servers          = join("", module.consul_cluster_vsis.*.https_endpoints) == "" ? [] : jsondecode(join("", module.consul_cluster_vsis.*.https_endpoints))
}
