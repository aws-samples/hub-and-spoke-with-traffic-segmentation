# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_route_tables/locals.tf ---

locals {
  is_inspection_prod     = lookup(var.vpc_types, "inspection-prod", "none") == "inspection-prod" ? true : false
  is_inspection_non_prod = lookup(var.vpc_types, "inspection-non-prod", "none") == "inspection-non-prod" ? true : false
  is_inspection          = lookup(var.vpc_types, "inspection", "none") == "inspection" ? true : false
}