## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

output "bastion_ssh_metadata" {
  value = oci_bastion_session.ssh_via_bastion_service.*.ssh_metadata
}

output "paloalto-firewall-server" {
  value = [oci_core_instance.paloalto-firewall-server.public_ip]
}
