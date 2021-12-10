## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn01" {
  cidr_block     = var.vcn01_cidr_block
  dns_label      = var.vcn01_dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.vcn01_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_vcn" "vcn02" {
  cidr_block     = var.vcn02_cidr_block
  dns_label      = var.vcn02_dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.vcn02_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#IGW
resource "oci_core_internet_gateway" "vcn01_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_internet_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_private_ip" "PaloAltoFirewallServer_vcn01_pub01_private_ip" {
  ip_address   = var.PaloAltoFirewallServer_vcn01_priv01_vnic_ip
  vnic_id      = data.oci_core_vnic_attachments.paloalto-firewall-server_vcn01pub01vnic_attachment.vnic_attachments.0.vnic_id
  display_name = "vcn01priv01vnic_private_ip"
}

resource "oci_core_private_ip" "PaloAltoFirewallServer_vcn01_pub02_private_ip" {
  ip_address   = var.PaloAltoFirewallServer_vcn01_priv02_vnic_ip
  vnic_id      = oci_core_vnic_attachment.paloalto-firewall-server_vcn01pub02vnic_attachment.vnic_id
  display_name = "vcn01priv02vnic_private_ip"
}

resource "oci_core_route_table" "vcn01_igw_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_igw_route_table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.vcn01_internet_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#NAT
resource "oci_core_nat_gateway" "vcn01_nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_nat_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_private_ip" "PaloAltoFirewallServer_vcn01_priv03_private_ip" {
  ip_address   = var.PaloAltoFirewallServer_vcn01_priv03_vnic_ip
  vnic_id      = oci_core_vnic_attachment.paloalto-firewall-server_vcn01priv03vnic_attachment.vnic_id
  display_name = "vcn01priv03vnic_private_ip"
}

resource "oci_core_route_table" "vcn01_paloalto_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_paloalto_route_table"
  route_rules {
    network_entity_id = oci_core_nat_gateway.vcn01_nat_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  route_rules {
    network_entity_id = oci_core_private_ip.PaloAltoFirewallServer_vcn01_priv03_private_ip.id
    destination       = var.vcn02_subnet_priv04_cidr_block
    destination_type  = "CIDR_BLOCK"
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_private_ip" "PaloAltoFirewallServer_vcn02_priv04_private_ip" {
  ip_address   = var.PaloAltoFirewallServer_vcn02_priv04_vnic_ip
  vnic_id      = oci_core_vnic_attachment.paloalto-firewall-server_vcn02priv04vnic_attachment.vnic_id
  display_name = "vcn02priv04vnic_private_ip"
}

resource "oci_core_route_table" "vcn02_paloalto_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn02.id
  display_name   = "vcn02_paloalto_route_table"

  route_rules {
    network_entity_id = oci_core_private_ip.PaloAltoFirewallServer_vcn02_priv04_private_ip.id
    destination       = var.vcn01_subnet_priv03_cidr_block
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


#vcn01 pub01 subnet
resource "oci_core_subnet" "vcn01_subnet_pub01" {
  cidr_block      = var.vcn01_subnet_pub01_cidr_block
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.vcn01.id
  display_name    = var.vcn01_subnet_pub01_display_name
  route_table_id  = oci_core_route_table.vcn01_igw_route_table.id
  dhcp_options_id = oci_core_vcn.vcn01.default_dhcp_options_id
  defined_tags    = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 pub02 subnet
resource "oci_core_subnet" "vcn01_subnet_pub02" {
  cidr_block      = var.vcn01_subnet_pub02_cidr_block
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.vcn01.id
  display_name    = var.vcn01_subnet_pub02_display_name
  route_table_id  = oci_core_route_table.vcn01_igw_route_table.id
  dhcp_options_id = oci_core_vcn.vcn01.default_dhcp_options_id
  defined_tags    = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 priv03 subnet 
resource "oci_core_subnet" "vcn01_subnet_priv03" {
  cidr_block                 = var.vcn01_subnet_priv03_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn01.id
  display_name               = var.vcn01_subnet_priv03_display_name
  dhcp_options_id            = oci_core_vcn.vcn01.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table_attachment" "vcn01_subnet_priv03_route_table_attachment" {
  subnet_id      = oci_core_subnet.vcn01_subnet_priv03.id
  route_table_id = oci_core_route_table.vcn01_paloalto_route_table.id
}

#vcn02 priv04 subnet 
resource "oci_core_subnet" "vcn02_subnet_priv04" {
  cidr_block                 = var.vcn02_subnet_priv04_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn02.id
  display_name               = var.vcn02_subnet_priv04_display_name
  dhcp_options_id            = oci_core_vcn.vcn02.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table_attachment" "vcn02_subnet_priv04_route_table_attachment" {
  subnet_id      = oci_core_subnet.vcn02_subnet_priv04.id
  route_table_id = oci_core_route_table.vcn02_paloalto_route_table.id
}
