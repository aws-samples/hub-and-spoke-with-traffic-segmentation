# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/network_firewall/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "vpc_name" {
  type        = string
  description = "VPC name."
}

variable "vpc_info" {
  type        = any
  description = "VPC Information."
}

variable "firewall_policy" {
  type        = string
  description = "ARN of the firewall policy to use."
}

variable "route_to_endpoint" {
  type        = string
  description = "CIDR block of the specific segment/region."
}