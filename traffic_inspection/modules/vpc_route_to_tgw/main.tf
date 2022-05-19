# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_route_to_tgw/main.tf ---

resource "aws_route" "private_to_tgw_route" {
  count = var.number_azs

  route_table_id         = var.route_tables[count.index]
  destination_cidr_block = var.cidr_blocks
  transit_gateway_id     = var.transit_gateway_id
}