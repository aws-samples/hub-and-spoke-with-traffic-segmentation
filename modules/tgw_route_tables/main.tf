# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_route_tables/main.tf ---

# TRANSIT GATEWAY ROUTE TABLES
# Production Route Table (Pre-Inspection if Inspection is added in the routing domain)
resource "aws_ec2_transit_gateway_route_table" "prod_rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_production-${var.identifier}"
  }
}

# Non-Production Route Table (Pre-Inspection if Inspection is added in the routin domain)
resource "aws_ec2_transit_gateway_route_table" "non_prod_rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_non_production-${var.identifier}"
  }
}

# Production Inspection Route Table
resource "aws_ec2_transit_gateway_route_table" "inspection_prod_rt" {
  count = var.traffic_inspection.prod ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_inspection_production-${var.identifier}"
  }
}

# Non-Production Inspection Route Table
resource "aws_ec2_transit_gateway_route_table" "inspection_non_prod_rt" {
  count = var.traffic_inspection.non-prod ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_inspection_non_production-${var.identifier}"
  }
}

# Cross-Domains Inspection Route Table
resource "aws_ec2_transit_gateway_route_table" "inspection_rt" {
  count = var.traffic_inspection.cross-domains ? 1 : 0

  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_inspection-${var.identifier}"
  }
}

# Shared Services Route Table
resource "aws_ec2_transit_gateway_route_table" "shared_rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "tgw_rt_shared_services-${var.identifier}"
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
  count = var.traffic_inspection.prod ? 1 : 0

  transit_gateway_attachment_id  = var.vpc_tgw_attachments["inspection-prod"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_prod_rt[0].id
}

# Inspection Non-Production VPC attachment to Inspection Non-Production Route Table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_non_prod_association" {
  count = var.traffic_inspection.non-prod ? 1 : 0

  transit_gateway_attachment_id  = var.vpc_tgw_attachments["inspection-non-prod"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_non_prod_rt[0].id
}

# Inspection Segments VPC attachment to Inspection Segments Route Table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_association" {
  count = var.traffic_inspection.cross-domains ? 1 : 0

  transit_gateway_attachment_id  = var.vpc_tgw_attachments["inspection"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt[0].id
}

# Shared Services VPC attachment to Shared Services Route Table
resource "aws_ec2_transit_gateway_route_table_association" "shared_services_association" {
  transit_gateway_attachment_id  = var.vpc_tgw_attachments["shared-services"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_rt.id
}

# TRANSIT GATEWAY PROPAGATION
# If there's not Inspection in Production, all the Production VPC attachments propagate to the Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "prod") && (!var.traffic_inspection.prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

# If there's not Inspection in Non-Production, all the Non-Production VPC attachments propagate to the Non-Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "non_prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "non-prod") && (!var.traffic_inspection.non-prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

# If there's Inspection in Production, all the Production VPC attachments propagate to the Inspection Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "prod") && (var.traffic_inspection.prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_prod_rt[0].id
}

# If there's Inspection in Non-Production, all the Non-Production VPC attachments propagate to the Inspection Non-Production Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_non_prod_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "non-prod") && (var.traffic_inspection.non-prod)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_non_prod_rt[0].id
}

# If there's Inspection between Routing Domains, all the Spoke VPC attachments propagate to the Inspection Segments Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_cross_domain_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if((var.vpc_types[k] == "prod") || (var.vpc_types[k] == "non-prod")) && (var.traffic_inspection.cross-domains)
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt[0].id
}

# Shared Services VPC attachment propagates to Prod and Non-Prod Route Tables
resource "aws_ec2_transit_gateway_route_table_propagation" "shared_services_to_production_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "shared-services")
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared_services_to_non_production_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "shared-services")
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

# All the Prod and Non-Prod VPCs propagate to the Shared Services Route Table
# If there's Inspection between Routing Domains, all the Spoke VPC attachments propagate to the Inspection Segments Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "vpcs_to_shared_services_propagation" {
  for_each = {
    for k, v in var.vpc_tgw_attachments : k => v
    if(var.vpc_types[k] == "prod") || (var.vpc_types[k] == "non-prod")
  }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_rt.id
}

# STATIC ROUTES
# If there's Inspection in Production, static route to Inspection Production VPC attachment in the Production Route Table
resource "aws_ec2_transit_gateway_route" "inspection_prod_static_route" {
  count = var.traffic_inspection.prod ? 1 : 0

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection-prod
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

# If there's Inspection in Non-Production, static route to Inspection Non-Production VPC attachment in the Non-Production Route Table
resource "aws_ec2_transit_gateway_route" "inspection_non_prod_static_route" {
  count = var.traffic_inspection.non-prod ? 1 : 0

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection-non-prod
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

# If there's Inspection between Segments, two static routes in both Prod and Non-Prod Route Tables sending to the Inspection (Cross-Domain) VPC attachment
resource "aws_ec2_transit_gateway_route" "inspection_segments_prod_static_route" {
  count = var.traffic_inspection.cross-domains ? 1 : 0

  destination_cidr_block         = var.segment_cidr_blocks.non_prod
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_rt.id
}

resource "aws_ec2_transit_gateway_route" "inspection_segments_non_prod_static_route" {
  count = var.traffic_inspection.cross-domains ? 1 : 0

  destination_cidr_block         = var.segment_cidr_blocks.prod
  transit_gateway_attachment_id  = var.vpc_tgw_attachments.inspection
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.non_prod_rt.id
}

