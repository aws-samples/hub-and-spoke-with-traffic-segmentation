# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/tgw_route_tables/outputs.tf ---

output "tgw_route_table_production" {
  value       = aws_ec2_transit_gateway_route_table.prod_rt
  description = "Production Transit Gateway Route Table."
}

output "tgw_route_table_non_production" {
  value       = aws_ec2_transit_gateway_route_table.non_prod_rt
  description = "Non-Production Transit Gateway Route Table."
}

output "tgw_route_table_inspection_production" {
  value       = local.is_inspection_prod ? aws_ec2_transit_gateway_route_table.inspection_prod_rt[0] : null
  description = "Inspection Production Transit Gateway Route Table."
}

output "tgw_route_table_inspection_non_production" {
  value       = local.is_inspection_non_prod ? aws_ec2_transit_gateway_route_table.inspection_non_prod_rt[0] : null
  description = "Inspection Production Transit Gateway Route Table."
}

output "tgw_route_table_inspection" {
  value       = local.is_inspection ? aws_ec2_transit_gateway_route_table.inspection_rt[0] : null
  description = "Inspection Production Transit Gateway Route Table."
}

