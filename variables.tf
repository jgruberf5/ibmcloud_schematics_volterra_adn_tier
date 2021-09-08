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
# ibm_vpc_name - The name for the IBM Gen2 VPC
##################################################################################
variable "ibm_vpc_name" {
  default     = ""
  description = "The name for the IBM Gen2 VPC"
}

##################################################################################
# ibm_vpc_index - The index ID for this IBM Gen2 VPC
##################################################################################
variable "ibm_vpc_index" {
  default     = "1"
  description = "The index ID for this IBM Gen2 VPC"
}

##################################################################################
# ibm_vpc_cidr - The IPv4 VPC cidr to use as the network prefix of the IBM Gen2 VPC
##################################################################################
variable "ibm_vpc_cidr" {
  default     = ""
  description = "The IPv4 VPC cidr to use as the network prefix of the IBM Gen2 VPC"
}

##################################################################################
# ibm_ssh_key_name - The name of the existing SSH key to inject into infrastructure
##################################################################################
variable "ibm_ssh_key_name" {
  default     = ""
  description = "The name of the existing SSH key to inject into infrastructure"
}

##################################################################################
# ibm_transit_gateway_id - The IBM transit gateway ID to connect the VPC
##################################################################################
variable "ibm_transit_gateway_id" {
  default     = ""
  description = "The IBM transit gateway ID to connect the VPC"
}

##################################################################################
# ibm_internal_networks - Internal reachable network IPv4 CIDRs
##################################################################################
variable "ibm_internal_networks" {
  type        = list(string)
  default     = []
  description = "Internal reachable network IPv4 CIDRs"
}

##################################################################################
# volterra_include_ce - Build VPC infrastructure for Volterra CE connectivity
##################################################################################
variable "volterra_include_ce" {
  type        = bool
  default     = true
  description = "Build VPC infrastructure for Volterra CE connectivity"
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
# volterra_ce_version - The IBM VPC profile for CE
##################################################################################
variable "volterra_ce_profile" {
  type        = string
  default     = "cx2-4x8"
  description = "The IBM VPC profile for CE"
}

##################################################################################
# volterra_ce_version - The version of Volterra CE image to Import
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
# volterra_api_token - The API token to use to register with Volterra
##################################################################################
variable "volterra_api_token" {
  type        = string
  default     = ""
  description = "The API token to use to register with Volterra"
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
# consul_include - create the Consul cluster instances
##################################################################################
variable "consul_include" {
  type        = bool
  default     = true
  description = "Create the Consul cluster instances"
}

##################################################################################
# consul_cluster_size - the Consul cluster size
##################################################################################
variable "consul_cluster_size" {
  type        = number
  default     = 3
  description = "The Consul cluster size"
}

##################################################################################
# consul_instance_profile - The name of the VPC profile to use for the Consul instances
##################################################################################
variable "consul_instance_profile" {
  type        = string
  default     = "cx2-4x8"
  description = "The name of the VPC profile to use for the Consul instances"
}

##################################################################################
# consul_client_token - UUID token used to register nodes and services 
##################################################################################
variable "consul_client_token" {
  type        = string
  default     = ""
  description = "UUID token used to register nodes and services"
}
