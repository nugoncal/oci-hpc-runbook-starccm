## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  listing_number = split(".", var.marketplace_listing)[0]
  mp_listing_id  = var.use_marketplace_image ? var.marketplace_listing_id[local.listing_number] : ""
}

/* 
output "debug" {
  value = data.oci_core_app_catalog_listing_resource_versions.app_catalog_listing_resource_versions.app_catalog_listing_resource_versions[0].listing_resource_id
}
*/

/*
data "oci_core_app_catalog_listing" "app_catalog_listing" {
    count = var.use_marketplace_image ? 1 : 0
    listing_id = local.mp_listing_id
}
*/

data "oci_core_app_catalog_listing_resource_versions" "app_catalog_listing_resource_versions" {
  count      = var.use_marketplace_image ? 1 : 0
  listing_id = local.mp_listing_id
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "mp_image_agreement" {
  count = var.use_marketplace_image ? 1 : 0

  listing_id               = local.mp_listing_id
  listing_resource_version = data.oci_core_app_catalog_listing_resource_versions.app_catalog_listing_resource_versions[0].app_catalog_listing_resource_versions[0].listing_resource_version

}

resource "oci_core_app_catalog_subscription" "mp_image_subscription" {
  count                    = var.use_marketplace_image && var.node_count > 0 ? 1 : 0
  compartment_id           = var.targetCompartment
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}
