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