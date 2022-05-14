# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "vpcs_id" {
  value       = { for k, v in module.vpcs : k => v.vpc_attributes.id }
  description = "VPCs created."
}

output "transit_gateway_id" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "Transit Gateway ID."
}

output "transit_gateway_route_table_production_id" {
  value       = module.tgw_route_tables.tgw_route_table_production.id
  description = "Transit Gateway Route Table ID - Production."
}

output "transit_gateway_route_table_non_production_id" {
  value       = module.tgw_route_tables.tgw_route_table_non_production.id
  description = "Transit Gateway Route Table ID - Non-Production."
}

output "vpc_endpoints" {
  value       = { for k, v in module.vpc_endpoints: k => v.endpoints_info }
  description = "Information about the VPC endpoints created."
}

output "ec2_instances" {
  value       = { for k, v in module.compute: k => v.instances_created }
  description = "Information about the EC2 instances created."
}