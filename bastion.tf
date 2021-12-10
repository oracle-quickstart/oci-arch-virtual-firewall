## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_bastion_bastion" "bastion-service" {
  count                        = var.use_bastion_service ? 1 : 0
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = oci_core_subnet.vcn01_subnet_pub02.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  defined_tags                 = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  name                         = "BastionService"
  max_session_ttl_in_seconds   = 1800
}

resource "oci_bastion_session" "ssh_via_bastion_service" {
  depends_on = [oci_core_instance.frontend-server,
    oci_core_nat_gateway.vcn01_nat_gateway,
    oci_core_network_security_group.SSHSecurityGroup,
    oci_core_network_security_group_security_rule.SSHSecurityEgressGroupRule,
    oci_core_network_security_group_security_rule.SSHSecurityIngressGroupRules
  ]

  count      = var.use_bastion_service ? 1 : 0
  bastion_id = oci_bastion_bastion.bastion-service[0].id

  key_details {
    public_key_content = tls_private_key.public_private_key_pair.public_key_openssh
  }
  target_resource_details {
    session_type       = "MANAGED_SSH"
    target_resource_id = oci_core_instance.frontend-server.id

    #Optional
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.frontend-server.private_ip
  }

  display_name           = "ssh_via_bastion_service_to_frontend-server"
  key_type               = "PUB"
  session_ttl_in_seconds = 1800
}
