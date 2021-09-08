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
# ibm_profile - The name of the VPC profile to use for the Consul instances
##################################################################################
variable "ibm_profile" {
  type        = string
  default     = "cx2-4x8"
  description = "The name of the VPC profile to use for the Consul instances"
}

##################################################################################
# ibm_ssh_key_name - The name of the existing SSH key to inject into infrastructure
##################################################################################
variable "ibm_ssh_key_name" {
  default = ""
  description = "The name of the existing SSH key to inject into infrastructure"
}

##################################################################################
# ibm_subnet_id - The VPC subnet ID to connect the Consul cluster 
##################################################################################
variable "ibm_subnet_id" {
  default = ""
  description = "The VPC subnet ID to connect the Consul cluster"
}

##################################################################################
# ibm_security_group_id - The VPC security group ID to connect the Consul cluster 
##################################################################################
variable "ibm_security_group_id" {
  default = ""
  description = "The VPC security group ID to connect the Consul cluster"
}

##################################################################################
# consul_cluster_size - Number of cluster nodes
##################################################################################
variable "consul_cluster_size" {
  type        = number
  default     = 3
  description = "Number of cluster nodes"
}

##################################################################################
# consul_organization - The organization for certificates
##################################################################################
variable "consul_organization" {
  type        = string
  default     = ""
  description = "The organization for certificates"
}

##################################################################################
# consul_datacenter - The datacenter for the Consul cluster
##################################################################################
variable "consul_datacenter" {
  type        = string
  default     = ""
  description = "The datacenter for the Consul cluster"
}

##################################################################################
# consul_client_token - UUID token used to register nodes and services 
##################################################################################
variable "consul_client_token" {
  type        = string
  default     = ""
  description = "UUID token used to register nodes and services"
}
