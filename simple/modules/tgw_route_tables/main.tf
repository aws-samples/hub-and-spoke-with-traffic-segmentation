# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_route_tables/main.tf ---

# TRANSIT GATEWAY ROUTE TABLES
resource "aws_ec2_transit_gateway_route_table" "prod_rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_production-${var.identifier}"
  }
}

resource "aws_ec2_transit_gateway_route_table" "non_prod_rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_production-${var.identifier}"
  }
}

# TRANSIT GATEWAY ASSOCIATIONS
resource "aws_ec2_transit_gateway_route_table_association" "prod_association" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "prod"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "non_prod_association" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "non-prod"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

# TRANSIT GATEWAY PROPAGATION
resource "aws_ec2_transit_gateway_route_table_propagation" "prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "prod"
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

# TRANSIT GATEWAY PROPAGATION
resource "aws_ec2_transit_gateway_route_table_propagation" "non_prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "non-prod"
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}