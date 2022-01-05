## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# PaloAltoFirewallServer 

resource "oci_core_instance" "paloalto-firewall-server" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "paloalto-firewall-server"
  shape               = var.PaloAltoFirewallServerShape

  dynamic "shape_config" {
    for_each = local.is_flexible_paloalto-firewall-server_shape ? [1] : []
    content {
      memory_in_gbs = var.PaloAltoFirewallServerFlexShapeMemory
      ocpus         = var.PaloAltoFirewallServerFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn01_subnet_pub01.id
    display_name           = "vcn01pub01vnic"
    assign_public_ip       = true
    skip_source_dest_check = true
    nsg_ids                = [oci_core_network_security_group.SSHSecurityGroup.id, oci_core_network_security_group.HTTPxSecurityGroup.id]
  }

  source_details {
    source_id               = lookup(data.oci_core_app_catalog_listing_resource_version.App_Catalog_Listing_Resource_Version, "listing_resource_id")
    source_type             = "image"
    boot_volume_size_in_gbs = "60"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_vnic_attachments" "paloalto-firewall-server_vcn01pub01vnic_attachment" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.paloalto-firewall-server.id
}

resource "oci_core_vnic_attachment" "paloalto-firewall-server_vcn01pub02vnic_attachment" {
  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn01_subnet_pub02.id
    display_name           = "vcn01pub02vnic"
    assign_public_ip       = false
    skip_source_dest_check = true
  }
  instance_id = oci_core_instance.paloalto-firewall-server.id
}

resource "oci_core_vnic_attachment" "paloalto-firewall-server_vcn01priv03vnic_attachment" {
  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn01_subnet_priv03.id
    display_name           = "vcn01priv03vnic"
    assign_public_ip       = false
    skip_source_dest_check = true
  }
  instance_id = oci_core_instance.paloalto-firewall-server.id
}

resource "oci_core_vnic_attachment" "paloalto-firewall-server_vcn02priv04vnic_attachment" {
  create_vnic_details {
    subnet_id              = oci_core_subnet.vcn02_subnet_priv04.id
    display_name           = "vcn02priv04vnic"
    assign_public_ip       = false
    skip_source_dest_check = true
  }
  instance_id = oci_core_instance.paloalto-firewall-server.id
}

# FrontendServer in VCN01/Subnet01

resource "oci_core_instance" "frontend-server" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "frontend-server"
  shape               = var.FrontendServerShape

  dynamic "shape_config" {
    for_each = local.is_flexible_frontend-server_shape ? [1] : []
    content {
      memory_in_gbs = var.FrontendServerFlexShapeMemory
      ocpus         = var.FrontendServerFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn01_subnet_pub01.id
    display_name     = "vcn01pub01vnic"
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.SSHSecurityGroup.id]
  }

  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.FrontendServerImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  # Needed for bastion agent to start on the compute
  provisioner "local-exec" {
    command = "sleep 240"
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# PrivateServer in VCN01/Subnet03

resource "oci_core_instance" "private-server" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "private-server"
  shape               = var.PrivateServerShape

  dynamic "shape_config" {
    for_each = local.is_flexible_private-server_shape ? [1] : []
    content {
      memory_in_gbs = var.PrivateServerFlexShapeMemory
      ocpus         = var.PrivateServerFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn01_subnet_priv03.id
    display_name     = "vcn01priv03vnic"
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.SSHSecurityGroup.id]
  }

  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.PrivateServerImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_vnic_attachments" "private-server_primaryvnic_attach" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.private-server.id
}

data "oci_core_vnic" "frontend-server_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.private-server_primaryvnic_attach.vnic_attachments.0.vnic_id
}


# BackendServer in VCN02/Subnet04

resource "oci_core_instance" "backend-server" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "backend-server"
  shape               = var.BackendServerShape

  dynamic "shape_config" {
    for_each = local.is_flexible_backend-server_shape ? [1] : []
    content {
      memory_in_gbs = var.BackendServerFlexShapeMemory
      ocpus         = var.BackendServerFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn02_subnet_priv04.id
    display_name     = "vcn02pub04vnic"
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.SSHSecurityGroup2.id]
  }

  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.FrontendServerImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_vnic_attachments" "backend-server_primaryvnic_attach" {
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.backend-server.id
}

data "oci_core_vnic" "backend-server_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.backend-server_primaryvnic_attach.vnic_attachments.0.vnic_id
}



