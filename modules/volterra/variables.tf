##################################################################################
# ibm_resource_group - The IBM Cloud resource group to create the VPC
##################################################################################
variable "ibm_resource_group" {
  type        = string
  default     = "default"
  description = "The IBM Cloud resource group to create the VPC"
}

##################################################################################
# ibm_region - The IBM Cloud VPC Gen 2 region to create VPC environment
##################################################################################
variable "ibm_region" {
  default     = "us-south"
  description = "The IBM Cloud VPC Gen 2 region to create VPC environment"
}

##################################################################################
# ibm_zone - The zone within the IBM Cloud region to create the VPC environment
##################################################################################
variable "ibm_zone" {
  default     = "1"
  description = "The zone within the IBM Cloud region to create the VPC environment"
}

##################################################################################
# ibm_profile - The name of the VPC profile to use for the CE instances
##################################################################################
variable "ibm_profile" {
  type        = string
  default     = "cx2-4x8"
  description = "The name of the VPC profile to use for the CE instances"
}

##################################################################################
# ibm_ssh_key_name - The name of the existing SSH key to inject into infrastructure
##################################################################################
variable "ibm_ssh_key_name" {
  default = ""
  description = "The ID of the existing SSH key to inject into infrastructure"
}

##################################################################################
# ibm_outside_subnet_id - Outside VPC subnet ID
##################################################################################
variable "ibm_outside_subnet_id" {
  type = string
  default = ""
  description = "Outside VPC subnet ID"
}

##################################################################################
# ibm_outside_security_group_id - The VPC security group ID to connect the Volterra CE cluster 
##################################################################################
variable "ibm_outside_security_group_id" {
  default = ""
  description = "The VPC security group ID to connect the Volterra CE cluster"
}

##################################################################################
# ibm_inside_subnet_id - Inside VPC subnet ID
##################################################################################
variable "ibm_inside_subnet_id" {
  type = string
  default = ""
  description = "Inside VPC subnet ID"
}

##################################################################################
# ibm_inside_security_group_id - The VPC security group ID to connect the Volterra CE cluster 
##################################################################################
variable "ibm_inside_security_group_id" {
  default = ""
  description = "The VPC security group ID to connect the Volterra CE cluster"
}

##################################################################################
# ibm_inside_gateway - Inside VPC subnet gateway
##################################################################################
variable "ibm_inside_gateway" {
  type = string
  default = ""
  description = "Inside VPC subnet gateway"
}

##################################################################################
# ibm_inside_networks - Inside reachable network IPv4 CIDRs
##################################################################################
variable "ibm_inside_networks" {
  type = list(string)
  default = [ ]
  description = "Inside reachable network IPv4 CIDRs"
}

##################################################################################
# volterra_cluster_size - The Volterra cluster size
##################################################################################
variable "volterra_cluster_size" {
  type        = number
  default     = 3
  description = "The Volterra cluster size"
}

##################################################################################
# volterra_download_region - The VPC region to Download the Public COS Images
##################################################################################
variable "volterra_download_region" {
  type        = string
  default     = "us-south"
  description = "The VPC region to Download the Public COS Images"
}

##################################################################################
# volterra_version - The version of Volterra CE image to Import
##################################################################################
variable "volterra_ce_version" {
  type        = string
  default     = "7.2009.5"
  description = "The version of Volterra CE image to Import"
}

##################################################################################
# volterra_tenant_name - The Volterra tenant (group) name
##################################################################################
variable "volterra_tenant_name" {
  type        = string
  default     = ""
  description = "The Volterra tenant (group) name"
}

##################################################################################
# volterra_site_name - The Volterra Site name for this VPC
##################################################################################
variable "volterra_site_name" {
  type        = string
  default     = ""
  description = "The Volterra Site name for this VPC"
}

##################################################################################
# volterra_fleet_label - The Volterra Fleet label for this VPC
##################################################################################
variable "volterra_fleet_label" {
  type        = string
  default     = ""
  description = "The Volterra Fleet label for this VPC"
}

##################################################################################
# volterra_api_token - The API token to use to register with Volterra
##################################################################################
variable "volterra_api_token" {
  type        = string
  default     = ""
  description = "The API token to use to register with Volterra"
}

##################################################################################
# volterra_admin_password - The password for the built-in admin Volterra user
##################################################################################
variable "volterra_admin_password" {
  type        = string
  default     = ""
  description = "The password for the built-in admin Volterra user"
}

##################################################################################
# volterra_ssl_tunnels - Use SSL tunnels to connect to Volterra
##################################################################################
variable "volterra_ssl_tunnels" {
  type        = bool
  default     = false
  description = "Use SSL tunnels to connect to Volterra"
}

##################################################################################
# volterra_ipsec_tunnels - Use IPSEC tunnels to connect to Volterra
##################################################################################
variable "volterra_ipsec_tunnels" {
  type        = bool
  default     = true
  description = "Use IPSEC tunnels to connect to Volterra"
}



##################################################################################
# consul_ca_cert - The CA certificate to register Consul service discovery
##################################################################################
variable "consul_ca_cert" {
  type = string
  default = ""
  description = "The CA certificate to register Consul service discovery"
}

##################################################################################
# consul_https_servers - The Consul servers to register with Consul service discovery
##################################################################################
variable "consul_https_servers" {
  type = list(string)
  default = []
  description = "The Consul servers to register with Consul service discovery"
}