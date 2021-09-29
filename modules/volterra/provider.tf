terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
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
