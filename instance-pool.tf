## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_volume" "nfs-instance-pool-volume" {
  count               = var.scratch_nfs_type_pool == "block" ? 1 : 0
  availability_domain = var.ad
  compartment_id      = var.targetCompartment
  display_name        = "${local.cluster_name}-nfs-volume"

  size_in_gbs = var.cluster_block_volume_size
  vpus_per_gb = split(".", var.cluster_block_volume_performance)[0]
}

resource "oci_core_volume_attachment" "instance_pool_volume_attachment" {
  count           = var.scratch_nfs_type_pool == "block" ? 1 : 0
  attachment_type = "iscsi"
  volume_id       = oci_core_volume.nfs-instance-pool-volume[0].id
  instance_id     = local.cluster_instances_ids[0]
  display_name    = "${local.cluster_name}-instance-pool-volume-attachment"
  device          = "/dev/oracleoci/oraclevdb"
}


resource "oci_core_instance_pool" "instance_pool" {
  count                     = (!var.cluster_network) && (var.node_count > 0) ? 1 : 0
  depends_on                = [oci_core_app_catalog_subscription.mp_image_subscription, oci_core_subnet.private-subnet, oci_core_subnet.public-subnet]
  compartment_id            = var.targetCompartment
  instance_configuration_id = oci_core_instance_configuration.instance_pool_configuration[0].id
  size                      = var.node_count
  display_name              = local.cluster_name

  placement_configurations {
    availability_domain = var.ad
    primary_subnet_id   = local.subnet_id
  }

  timeouts {
    create = "180m"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

