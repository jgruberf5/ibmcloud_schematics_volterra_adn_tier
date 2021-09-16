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
# ibm_resource_group - The IBM Cloud resource group to create the VPC
##################################################################################
variable "ibm_resource_group" {
  type        = string
  default     = "default"
  description = "The IBM Cloud resource group to create the VPC"
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