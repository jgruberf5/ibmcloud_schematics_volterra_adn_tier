terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.30.2"
    }
  }
}

# Configure the IBM Provider
provider "ibm" {
  region = var.ibm_region
}

data "ibm_is_region" "vpc_region" {
  name = var.ibm_region
}

data "ibm_resource_group" "group" {
  name = var.ibm_resource_group
}