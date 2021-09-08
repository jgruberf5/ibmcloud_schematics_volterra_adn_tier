data "ibm_resource_group" "group" {
  name = var.ibm_resource_group
}

data "ibm_is_ssh_key" "ssh_key" {
  name = var.ibm_ssh_key_name
}

data "ibm_is_subnet" "outside_subnet" {
  identifier = var.ibm_outside_subnet_id
}

data "ibm_is_subnet" "inside_subnet" {
  count      = var.ibm_inside_subnet_id == "" ? 1 : 0
  identifier = var.ibm_inside_subnet_id
}

# create a random password if we need it
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_uuid" "namer" {}

locals {
  # user admin_password if supplied, else set a random password
  admin_password = var.volterra_admin_password == "" ? random_password.admin_password.result : var.volterra_admin_password
  vpc_gen2_region_location_map = {
    "au-syd" = {
      "latitude"  = "-33.8688",
      "longitude" = "151.2093"
    },
    "ca-tor" = {
      "latitude"  = "43.6532",
      "longitude" = "-79.3832"
    },
    "eu-de" = {
      "latitude"  = "50.1109",
      "longitude" = "8.6821"
    },
    "eu-gb" = {
      "latitude"  = "51.5074",
      "longitude" = "0.1278"
    },
    "jp-osa" = {
      "latitude"  = "34.6937",
      "longitude" = "135.5023"
    },
    "jp-tok" = {
      "latitude"  = "35.6762",
      "longitude" = "139.6503"
    },
    "us-east" = {
      "latitude"  = "38.9072",
      "longitude" = "-77.0369"
    },
    "us-south" = {
      "latitude"  = "32.7924",
      "longitude" = "-96.8147"
    }
  }
  outside_security_group_id = var.ibm_outside_security_group_id == "" ? data.ibm_is_subnet.outside_subnet.default_security_group : var.ibm_outside_security_group_id
  inside_security_group_id  = var.ibm_inside_subnet_id == "" ? "" : var.ibm_inside_security_group_id == "" ? data.ibm_is_subnet.inside_subnet.default_security_group : var.ibm_inside_security_group_id
  inside_gateway = var.ibm_inside_subnet_id == "" ? "" : var.ibm_inside_gateway == "" ? cidrhost(data.ibm_is_subnet.inside_subnet.ipv4_cidr_block, 1) : var.ibm_inside_gateway
  inside_nic                = "eth1"
  secondary_subnets         = var.ibm_inside_subnet_id == "" ? compact(list("")) : compact(list(var.ibm_inside_subnet_id))
  certified_hardware        = "kvm-multi-nic-voltstack-combo"
  template_file             = file("${path.module}/volterra_voltmesh_ce.yaml")
  create_fip_count          = var.volterra_ipsec_tunnels ? var.volterra_cluster_size : 0
  cluster_masters           = var.volterra_cluster_size > 2 ? 3 : 1
  fleet_label = var.volterra_fleet_label == "" ? "${var.volterra_site_name}-fleet" : var.volterra_fleet_label
}

# lookup compute profile by name
data "ibm_is_instance_profile" "instance_profile" {
  name = var.ibm_profile
}

resource "local_file" "complete_flag" {
  filename   = "${path.module}/complete.flag"
  content    = uuid()
  depends_on = [null_resource.site_registration]
}

resource "null_resource" "site" {
  triggers = {
    tenant          = var.volterra_tenant
    token           = var.volterra_api_token
    site_name       = var.volterra_site_name
    fleet_label     = local.fleet_label
    voltstack       = var.voltstack ? "true" : "false"
    cluster_size    = var.volterra_cluster_size,
    latitude        = lookup(local.vpc_gen2_region_location_map, var.ibm_region).latitude
    longitude       = lookup(local.vpc_gen2_region_location_map, var.ibm_region).longitude
    inside_networks = jsonencode(var.ibm_inside_networks)
    inside_gateway  = local.ibm_inside_gateway
    consul_servers  = jsonencode(var.consul_https_servers)
    ca_cert_encoded = base64encode(var.consul_ca_cert)
    # always force update
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    when       = create
    command    = "${path.module}/volterra_resource_site_create.py --site '${self.triggers.site_name}' --fleet '${self.triggers.fleet_label}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}' --voltstack '${self.triggers.voltstack}' --k8sdomain '${self.triggers.site_name}.infra' --cluster_size  '${self.triggers.cluster_size}' --latitude '${self.triggers.latitude}' --longitude '${self.triggers.longitude}' --inside_networks '${self.triggers.inside_networks}' --inside_gateway '${self.triggers.inside_gateway}' --consul_servers '${self.triggers.consul_servers}' --ca_cert_encoded '${self.triggers.ca_cert_encoded}'"
    on_failure = fail
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "${path.module}/volterra_resource_site_destroy.py --site '${self.triggers.site_name}' --fleet '${self.triggers.fleet_label}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}' --voltstack '${self.triggers.voltstack}'"
    on_failure = fail
  }
}

data "local_file" "site_token" {
  filename   = "${path.module}/${var.volterra_site_name}_site_token.txt"
  depends_on = [null_resource.site]
}


data "template_file" "user_data" {
  template = local.template_file
  vars = {
    admin_password     = local.admin_password
    cluster_name       = var.volterra_site_name
    fleet_label        = local.fleet_label
    certified_hardware = local.certified_hardware
    latitude           = lookup(local.vpc_gen2_region_location_map, var.ibm_region).latitude
    longitude          = lookup(local.vpc_gen2_region_location_map, var.ibm_region).longitude
    site_token         = data.local_file.site_token.content
    profile            = local.ce_profile
    inside_nic         = local.inside_nic
    region             = var.region
  }
  depends_on = [data.local_file.site_token]
}

# create compute instance
resource "ibm_is_instance" "ce_instance" {
  count          = var.volterra_cluster_size
  name           = "${var.volterra_site_name}-vce-${count.index}"
  resource_group = data.ibm_resource_group.group.id
  image          = ibm_is_image.ce_custom_image.id
  profile        = data.ibm_is_instance_profile.instance_profile.id
  primary_network_interface {
    name              = "outside"
    subnet            = var.ibm_outside_subnet_id
    security_groups   = [local.outside_security_group_id]
    allow_ip_spoofing = true
  }
  dynamic "network_interfaces" {
    for_each = local.secondary_subnets
    content {
      name              = "inside"
      subnet            = network_interfaces.value
      security_groups   = [local.inside_security_group_id]
      allow_ip_spoofing = true
    }
  }
  vpc       = data.ibm_is_subnet.outside_subnet.vpc
  zone      = data.ibm_is_subnet.outside_subnet.zone
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
  user_data = data.template_file.user_data.rendered
  timeouts {
    create = "60m"
    delete = "120m"
  }
  depends_on = [data.local_file.site_token]
}

resource "ibm_is_floating_ip" "external_floating_ip" {
  count          = local.create_fip_count
  name           = "fip-${var.volterra_site_name}-vce-${count.index}"
  resource_group = data.ibm_resource_group.group.id
  target         = element(ibm_is_instance.ce_instance.*.primary_network_interface.0.id, count.index)
}

resource "null_resource" "site_registration" {

  triggers = {
    site                = var.volterra_site_name,
    tenant              = var.volterra_tenant
    token               = var.volterra_api_token
    size                = local.cluster_masters,
    allow_ssl_tunnels   = var.volterra_ssl_tunnels ? "true" : "false"
    allow_ipsec_tunnels = var.volterra_ipsec_tunnels ? "true" : "false"
    voltstack           = "false"
  }

  depends_on = [ibm_is_instance.ce_instance]

  provisioner "local-exec" {
    when       = create
    command    = "${path.module}/volterra_site_registration_actions.py --delay 60 --action 'registernodes' --site '${self.triggers.site}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}' --ssl ${self.triggers.allow_ssl_tunnels} --ipsec ${self.triggers.allow_ipsec_tunnels} --size ${self.triggers.size} --voltstack '${self.triggers.voltstack}'"
    on_failure = fail
  }

}
