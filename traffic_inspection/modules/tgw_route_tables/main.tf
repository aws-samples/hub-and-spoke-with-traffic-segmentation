# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_route_tables/main.tf ---

# TRANSIT GATEWAY ROUTE TABLES
# Production Route Table (Pre-Inspection if Inspection is added)
resource "aws_ec2_transit_gateway_route_table" "prod_rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_production-${var.identifier}"
  }
}

# Non-Production Route Table (Pre-Inspection if Inspection is added)
resource "aws_ec2_transit_gateway_route_table" "non_prod_rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_non_production-${var.identifier}"
  }
}

# Production Inspection Route Table
resource "aws_ec2_transit_gateway_route_table" "inspection_prod_rt" {
  count = local.is_inspection_prod ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_inspection_production-${var.identifier}"
  }
}

# Non-Production Inspection Route Table
resource "aws_ec2_transit_gateway_route_table" "inspection_non_prod_rt" {
  count = local.is_inspection_non_prod ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_inspection_non_production-${var.identifier}"
  }
}

# Cross-Segments Inspection Route Table
resource "aws_ec2_transit_gateway_route_table" "inspection_rt" {
  count = local.is_inspection ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_inspection-${var.identifier}"
  }
}

# TRANSIT GATEWAY ASSOCIATIONS
# Production Spoke VPC attachments to Production Route Table
resource "aws_ec2_transit_gateway_route_table_association" "prod_association" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "prod"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

# Non-Production Spoke VPC attachments to Non-Production Route Table 
resource "aws_ec2_transit_gateway_route_table_association" "non_prod_association" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if var.vpc_types[k] == "non-prod"
  }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

# Inspection Production VPC attachment to Inspection Production Route Table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_prod_association" {
  count = local.is_inspection_prod ? 1 : 0

  transit_gateway_attachment_id  = var.vpc_tgw_attachments["inspection-prod"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_prod_rt[0].id
}

# Inspection Non-Production VPC attachment to Inspection Non-Production Route Table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_non_prod_association" {
  count = local.is_inspection_non_prod ? 1 : 0

  transit_gateway_attachment_id  = var.vpc_tgw_attachments["inspection-non-prod"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_non_prod_rt[0].id
}

# Inspection Segments VPC attachment to Inspection Segments Route Table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_association" {
  count = local.is_inspection ? 1 : 0

  transit_gateway_attachment_id  = var.vpc_tgw_attachments["inspection"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt[0].id
}

# TRANSIT GATEWAY PROPAGATION
# If there's not Inspection in Production, all the Production VPC attachments propagate to the Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "prod") && (!local.is_inspection_prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

# If there's not Inspection in Non-Production, all the Non-Production VPC attachments propagate to the Non-Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "non_prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "non-prod") && (!local.is_inspection_non_prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

# If there's Inspection in Production, all the Production VPC attachments propagate to the Inspection Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "prod") && (local.is_inspection_prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_prod_rt[0].id
}

# If there's Inspection in Non-Production, all the Non-Production VPC attachments propagate to the Inspection Non-Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_non_prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "non-prod") && (local.is_inspection_non_prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_non_prod_rt[0].id
}

# If there's Inspection between Segments, all the Spoke VPC attachments propagate to the Inspection Segments Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_segments_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if((var.vpc_types[k] == "prod") || (var.vpc_types[k] == "non-prod")) && (local.is_inspection)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt[0].id
}

# STATIC ROUTES
# If there's Inspection in Production, static route to Inspection Production VPC attachment in the Production Route Table
resource "aws_ec2_transit_gateway_route" "inspection_prod_static_route" {
  count = local.is_inspection_prod ? 1 : 0

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection-prod
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

# If there's Inspection in Non-Production, static route to Inspection Non-Production VPC attachment in the Non-Production Route Table
resource "aws_ec2_transit_gateway_route" "inspection_non_prod_static_route" {
  count = local.is_inspection_non_prod ? 1 : 0

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection-non-prod
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

# If there's Inspection between Segments, two static routes in both Prod and Non-Prod Route Tables sending to the Inspection Segments VPC attachment
resource "aws_ec2_transit_gateway_route" "inspection_segments_prod_static_route" {
  count = local.is_inspection ? 1 : 0

  destination_cidr_block         = var.segment_cidr_blocks.non_prod
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

resource "aws_ec2_transit_gateway_route" "inspection_segments_non_prod_static_route" {
  count = local.is_inspection ? 1 : 0

  destination_cidr_block         = var.segment_cidr_blocks.prod
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

