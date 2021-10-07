# get the public image COS SQL url and default name
data "external" "volterra_public_image" {
  program = ["python3", "${path.module}/volterra_image_selector.py"]
  query = {
    download_region = var.volterra_download_region
    version_prefix  = var.volterra_ce_version
  }
}
#resource "ibm_is_image" "ce_custom_image" {
#  name             = "vce-adn-${random_uuid.namer.result}"
#  resource_group   = data.ibm_resource_group.group.id
#  href             = data.external.volterra_public_image.result.image_sql_url
#  operating_system = "centos-7-amd64"
#  timeouts {
#    create = "60m"
#    delete = "60m"
#  }
#}

data "ibm_is_image" "ce_image" {
    identifier = data.external.volterra_public_image.result.image_id
}