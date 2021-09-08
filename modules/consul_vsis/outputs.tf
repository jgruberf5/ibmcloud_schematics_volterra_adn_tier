locals {
  host_1           = var.cluster_size > 0 ? join("", ibm_is_instance.consul_server_01_instance.*.primary_network_interface.0.primary_ipv4_address) : ""
  http_endpoints_1 = local.host_1 == "" ? list("") : list("${local.host_1}:8501")
  dns_endpoints_1  = local.host_1 == "" ? list("") : list("${local.host_1}:8600")
  host_2           = var.cluster_size > 1 ? join("", ibm_is_instance.consul_server_02_instance.*.primary_network_interface.0.primary_ipv4_address) : ""
  http_endpoints_2 = local.host_2 == "" ? local.http_endpoints_1 : concat(local.http_endpoints_1, list("${local.host_2}:8501"))
  dns_endpoints_2  = local.host_2 == "" ? local.dns_endpoints_1 : concat(local.dns_endpoints_1, list("${local.host_2}:8600"))
  host_3         = var.cluster_size > 2 ? join("", ibm_is_instance.consul_server_03_instance.*.primary_network_interface.0.primary_ipv4_address) : ""
  http_endpoints = local.host_3 == "" ? local.http_endpoints_2 : concat(local.http_endpoints_2, list("${local.host_3}:8501"))
  dns_endpoints  = local.host_3 == "" ? local.dns_endpoints_2 : concat(local.dns_endpoints_2, list("${local.host_3}:8600"))
}

output "datacenter" {
  value = var.datacenter
}

output "datacenter_ca_certificate" {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output "client_token" {
  value = local.client_token
}

output "https_endpoints" {
  value = jsonencode(local.http_endpoints)
}

output "dns_endpoints" {
  value = jsonencode(local.dns_endpoints)
}

output "ca_p12" {
  value = data.external.publish_pkcs12.result.ca_p12_b64
}

output "encrypt" {
  value = base64encode(random_string.consul_cluster_key.result)
}
