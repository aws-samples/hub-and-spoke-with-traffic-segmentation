# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_route_tables/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project Name, used as identifer when creating resources."
}

variable "transit_gateway_id" {
  type        = string
  description = "ID of the Transit Gateway created."
}

variable "vpc_tgw_attachments" {
  type        = map(string)
  description = "ID of the TGW attachments created - Spoke VPCs."
}

variable "vpc_types" {
  type        = map(string)
  description = "List of VPC types - for route table association and propagation."
}

variable "segment_cidr_blocks" {
  type        = map(string)
  description = "CIDR blocks of the different segments."
}

variable "traffic_inspection" {
  type        = map(bool)
  description = "Variable (defined in root) indicating the type of traffic inspection to add."
}