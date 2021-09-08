data "ibm_resource_group" "group" {
  name = var.ibm_resource_group
}

# lookup compute profile by name
data "ibm_is_instance_profile" "consul_instance_profile" {
  name = var.ibm_profile
}

# lookup image name for a custom image in region if we need it
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

data "ibm_is_ssh_key" "ssh_key" {
  name = var.ibm_ssh_key_name
}

data "ibm_is_subnet" "consul_subnet" {
  identifier = var.ibm_subnet_id
}

data "ibm_is_vpc" "consul_vpc" {
  name = data.ibm_is_subnet.consul_subnet.vpc_name
}

resource "random_string" "consul_cluster_key" {
  length  = 16
  special = false
}

resource "tls_private_key" "ca_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}
resource "tls_self_signed_cert" "ca_cert" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.ca_key.private_key_pem
  subject {
    common_name  = "${var.consul_datacenter}-ca.consul"
    organization = var.consul_organization
  }
  validity_period_hours = 87659
  is_ca_certificate     = true
  set_subject_key_id    = true
  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_private_key" "server_01_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "server_01_cert_request" {
  key_algorithm   = tls_private_key.server_01_cert.algorithm
  private_key_pem = tls_private_key.server_01_cert.private_key_pem
  dns_names = [
    "localhost",
    "server.${var.consul_datacenter}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.consul_datacenter}-server-01.consul"
    organization = var.consul_organization
  }
}

resource "tls_locally_signed_cert" "server_01_signed" {
  cert_request_pem      = tls_cert_request.server_01_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca_cert.cert_pem
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "server_02_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "server_02_cert_request" {
  key_algorithm   = tls_private_key.server_02_cert.algorithm
  private_key_pem = tls_private_key.server_02_cert.private_key_pem
  dns_names = [
    "localhost",
    "server.${var.consul_datacenter}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.consul_datacenter}-server-02.consul"
    organization = var.consul_organization
  }
}

resource "tls_locally_signed_cert" "server_02_signed" {
  cert_request_pem      = tls_cert_request.server_02_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca_cert.cert_pem
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "server_03_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "server_03_cert_request" {
  key_algorithm   = tls_private_key.server_03_cert.algorithm
  private_key_pem = tls_private_key.server_03_cert.private_key_pem
  dns_names = [
    "localhost",
    "server.${var.consul_datacenter}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.consul_datacenter}-server-03.consul"
    organization = var.consul_organization
  }
}

resource "tls_locally_signed_cert" "server_03_signed" {
  cert_request_pem      = tls_cert_request.server_03_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca_cert.cert_pem
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "client_cert" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "client_cert_request" {
  key_algorithm   = tls_private_key.client_cert.algorithm
  private_key_pem = tls_private_key.client_cert.private_key_pem
  dns_names = [
    "localhost",
    "client.${var.consul_datacenter}.consul",
    "volterra-discovery.consul"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "${var.consul_datacenter}-client.consul"
    organization = var.consul_organization
  }
}

resource "tls_locally_signed_cert" "client_signed" {
  cert_request_pem      = tls_cert_request.client_cert_request.cert_request_pem
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca_cert.cert_pem
  validity_period_hours = 87659
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

locals {
  cluster_master_token = uuid()
  server_agent_token   = uuid()
  client_token         = var.consul_client_token == "" ? uuid() : var.consul_client_token
  security_group_id    = var.ibm_security_group_id == "" ? data.ibm_is_vpc.consul_vpc.default_security_group : var.ibm_security_group_id
}

data "template_file" "consul_server_01" {
  template = file("${path.module}/consul_server_01.yaml")
  vars = {
    ca_cert_chain        = indent(4, tls_self_signed_cert.ca_cert.cert_pem)
    server_01_cert       = indent(4, tls_locally_signed_cert.server_01_signed.cert_pem)
    server_01_key        = indent(4, tls_private_key.server_01_cert.private_key_pem)
    client_cert          = indent(4, tls_locally_signed_cert.client_signed.cert_pem)
    client_key           = indent(4, tls_private_key.client_cert.private_key_pem)
    cluster_encrypt_key  = base64encode(random_string.consul_cluster_key.result)
    cluster_master_token = local.cluster_master_token
    server_agent_token   = local.server_agent_token
    client_token         = local.client_token
    datacenter           = var.consul_datacenter
  }
}

# create server 01
resource "ibm_is_instance" "consul_server_01_instance" {
  name           = "${var.consul_datacenter}-consul-01"
  count          = var.consul_cluster_size > 0 ? 1 : 0
  resource_group = data.ibm_resource_group.group.id
  image          = data.ibm_is_image.ubuntu.id
  profile        = data.ibm_is_instance_profile.consul_instance_profile.id
  primary_network_interface {
    name            = "internal"
    subnet          = data.ibm_is_subnet.consul_subnet.id
    security_groups = [local.security_group_id]
  }
  vpc       = data.ibm_is_subnet.consul_subnet.vpc
  zone      = data.ibm_is_subnet.consul_subnet.zone
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
  user_data = data.template_file.consul_server_01.rendered
  timeouts {
    create = "60m"
    delete = "120m"
  }
}
data "template_file" "consul_server_02" {
  template = file("${path.module}/consul_server_02.yaml")
  vars = {
    ca_cert_chain        = indent(4, tls_self_signed_cert.ca_cert.cert_pem)
    server_02_cert       = indent(4, tls_locally_signed_cert.server_02_signed.cert_pem)
    server_02_key        = indent(4, tls_private_key.server_02_cert.private_key_pem)
    client_cert          = indent(4, tls_locally_signed_cert.client_signed.cert_pem)
    client_key           = indent(4, tls_private_key.client_cert.private_key_pem)
    cluster_encrypt_key  = base64encode(random_string.consul_cluster_key.result)
    cluster_master_token = local.cluster_master_token
    server_agent_token   = local.server_agent_token
    client_token         = local.client_token
    datacenter           = var.consul_datacenter
    server_1_ip_address  = ibm_is_instance.consul_server_01_instance.0.primary_network_interface.0.primary_ipv4_address
  }
}

# create server 02
resource "ibm_is_instance" "consul_server_02_instance" {
  name           = "${var.consul_datacenter}-consul-02"
  count          = var.consul_cluster_size > 1 ? 1 : 0
  resource_group = data.ibm_resource_group.group.id
  image          = data.ibm_is_image.ubuntu.id
  profile        = data.ibm_is_instance_profile.consul_instance_profile.id
  primary_network_interface {
    name            = "internal"
    subnet          = data.ibm_is_subnet.consul_subnet.id
    security_groups = [local.security_group_id]
  }
  vpc       = data.ibm_is_subnet.consul_subnet.vpc
  zone      = data.ibm_is_subnet.consul_subnet.zone
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
  user_data = data.template_file.consul_server_02.rendered
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

data "template_file" "consul_server_03" {
  template = file("${path.module}/consul_server_03.yaml")
  vars = {
    ca_cert_chain        = indent(4, tls_self_signed_cert.ca_cert.cert_pem)
    server_03_cert       = indent(4, tls_locally_signed_cert.server_03_signed.cert_pem)
    server_03_key        = indent(4, tls_private_key.server_03_cert.private_key_pem)
    client_cert          = indent(4, tls_locally_signed_cert.client_signed.cert_pem)
    client_key           = indent(4, tls_private_key.client_cert.private_key_pem)
    cluster_encrypt_key  = base64encode(random_string.consul_cluster_key.result)
    cluster_master_token = local.cluster_master_token
    server_agent_token   = local.server_agent_token
    client_token         = local.client_token
    datacenter           = var.consul_datacenter
    server_1_ip_address  = ibm_is_instance.consul_server_01_instance.0.primary_network_interface.0.primary_ipv4_address
    server_2_ip_address  = var.consul_cluster_size > 2 ? ibm_is_instance.consul_server_02_instance.0.primary_network_interface.0.primary_ipv4_address : ""
  }
}

# create server 03
resource "ibm_is_instance" "consul_server_03_instance" {
  name           = "${var.consul_datacenter}-consul-03"
  count          = var.consul_cluster_size > 2 ? 1 : 0
  resource_group = data.ibm_resource_group.group.id
  image          = data.ibm_is_image.ubuntu.id
  profile        = data.ibm_is_instance_profile.consul_instance_profile.id
  primary_network_interface {
    name            = "internal"
    subnet          = data.ibm_is_subnet.consul_subnet.id
    security_groups = [local.security_group_id]
  }
  vpc       = data.ibm_is_subnet.consul_subnet.vpc
  zone      = data.ibm_is_subnet.consul_subnet.zone
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
  user_data = data.template_file.consul_server_03.rendered
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

# publish consul pkcs12 package
data "external" "publish_pkcs12" {
  program = ["python3", "${path.module}/publish_pkcs12.py"]
  query = {
    ca_cert    = tls_self_signed_cert.ca_cert.cert_pem
    ca_key     = tls_private_key.ca_key.private_key_pem
    passphrase = base64encode(random_string.consul_cluster_key.result)
  }
}
