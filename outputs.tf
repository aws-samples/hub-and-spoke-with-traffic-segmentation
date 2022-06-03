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

output "transit_gateway_route_tables" {
  value       = { for k, v in module.tgw_route_tables : k => v.id if v != null}
  description = "TGW Route Tables ID created."
}

output "vpc_endpoints" {
  value       = { for k, v in module.vpc_endpoints : k => v.endpoints_info }
  description = "ID of the VPC endpoints created."
}

output "ec2_instances" {
  value       = { for k, v in module.compute : k => v.instances_created }
  description = "ID of the EC2 instances created."
}

output "network_firewall" {
  value       = { for k, v in module.anfw : k => v.network_firewall.arn }
  description = "ARN of the Network Firewall resources created."
}