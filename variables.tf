## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}

variable "ssh_public_key" {
  default = ""
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0"
}

variable "availablity_domain_name" {
  default = ""
}
variable "availablity_domain_number" {
  default = 0
}

variable "use_bastion_service" {
  default = false
}

variable "igw_display_name" {
  default = "internet-gateway"
}

variable "vcn01_cidr_block" {
  default = "10.0.0.0/16"
}
variable "vcn01_dns_label" {
  default = "vcn01"
}
variable "vcn01_display_name" {
  default = "vcn01"
}

variable "vcn01_subnet_pub01_cidr_block" {
  default = "10.0.1.0/24"
}

variable "vcn01_subnet_pub01_display_name" {
  default = "vcn01_subnet_pub01"
}

variable "vcn01_subnet_pub02_cidr_block" {
  default = "10.0.2.0/24"
}

variable "vcn01_subnet_pub02_display_name" {
  default = "vcn01_subnet_pub02"
}

variable "vcn01_subnet_priv03_cidr_block" {
  default = "10.0.3.0/24"
}

variable "vcn01_subnet_priv03_display_name" {
  default = "vcn01_subnet_app01"
}

variable "vcn02_cidr_block" {
  default = "10.1.0.0/16"
}
variable "vcn02_dns_label" {
  default = "vcn02"
}
variable "vcn02_display_name" {
  default = "vcn02"
}

variable "vcn02_subnet_priv04_cidr_block" {
  default = "10.1.1.0/24"
}

variable "vcn02_subnet_priv04_display_name" {
  default = "vcn02_subnet_priv04"
}

# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "FrontendServerShape" {
  default = "VM.Standard.E3.Flex"
}

variable "FrontendServerFlexShapeOCPUS" {
  default = 1
}

variable "FrontendServerFlexShapeMemory" {
  default = 10
}

variable "BackendServerShape" {
  default = "VM.Standard.E3.Flex"
}

variable "BackendServerFlexShapeOCPUS" {
  default = 1
}

variable "BackendServerFlexShapeMemory" {
  default = 10
}

variable "PrivateServerShape" {
  default = "VM.Standard.E3.Flex"
}

variable "PrivateServerFlexShapeOCPUS" {
  default = 1
}

variable "PrivateServerFlexShapeMemory" {
  default = 10
}

variable "FirewallServerShape" {
  default = "VM.Standard2.4"
}

variable "FirewallServerFlexShapeOCPUS" {
  default = 1
}

variable "FirewallServerFlexShapeMemory" {
  default = 10
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_frontend-server_shape = contains(local.compute_flexible_shapes, var.FrontendServerShape)
  is_flexible_backend-server_shape  = contains(local.compute_flexible_shapes, var.BackendServerShape)
  is_flexible_private-server_shape  = contains(local.compute_flexible_shapes, var.PrivateServerShape)
  is_flexible_firewall-server_shape = contains(local.compute_flexible_shapes, var.FirewallServerShape)
}



