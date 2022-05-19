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
  description = "Type of the VPCs (prod or non-prod) created."
}

variable "segment_cidr_blocks" {
  type        = map(string)
  description = "CIDR blocks of the different segments."
}