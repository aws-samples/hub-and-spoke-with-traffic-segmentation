# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/network_firewall/main.tf ---

# AWS NETWORK FIREWALL RESOURCE
resource "aws_networkfirewall_firewall" "anfw" {
  name                = "ANFW-${var.vpc_name}-${var.identifier}"
  firewall_policy_arn = var.firewall_policy
  vpc_id              = var.vpc_info.vpc_attributes.id

  dynamic "subnet_mapping" {
    for_each = values({ for k, v in var.vpc_info.private_subnet_attributes_by_az : k => v.id })

    content {
      subnet_id = subnet_mapping.value
    }
  }
}

# ROUTING TO THE FIREWALL ENDOINTS
# Transit Gateway Route Tables
resource "awscc_ec2_route_table" "tgw_route_table" {
  for_each = { for k, v in var.vpc_info.tgw_subnet_attributes_by_az : k => v.id }

  vpc_id = var.vpc_info.vpc_attributes.id

  tags = concat([{ "key" = "Name", "value" = "tgw-${each.key}" }])
}

# Route Table - Subnet Association
resource "awscc_ec2_subnet_route_table_association" "tgw_route_table_association" {
  for_each = { for k, v in var.vpc_info.tgw_subnet_attributes_by_az : k => v.id }

  route_table_id = awscc_ec2_route_table.tgw_route_table[each.key].id
  subnet_id      = each.value
}

# Route from the TGW Subnet to 0.0.0.0/0 via the firewall endpoint
resource "aws_route" "tgw_to_firewall_endpoint" {
  for_each = { for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id }

  route_table_id         = awscc_ec2_route_table.tgw_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = each.value
}

# Route from the Public Subnet to the Segment CIDR block via the firewall endpoint
resource "aws_route" "public_to_firewall_endpoint" {
  for_each = { 
    for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id 
    if var.vpc_name != "inspection"
  }

  route_table_id         = var.vpc_info.route_table_by_subnet_type.public[each.key].id
  destination_cidr_block = var.route_to_endpoint
  vpc_endpoint_id        = each.value
}

# # LOGGING
# # Logging Configuration
# resource "aws_networkfirewall_logging_configuration" "anfw_logs" {
#   firewall_arn = aws_networkfirewall_firewall.anfw.arn
#   logging_configuration {

#     log_destination_config {
#       log_destination = {
#         logGroup = aws_cloudwatch_log_group.anfwlogs_lg_flow.name
#       }
#       log_destination_type = "CloudWatchLogs"
#       log_type             = "FLOW"
#     }

#     log_destination_config {
#       log_destination = {
#         logGroup = aws_cloudwatch_log_group.anfwlogs_lg_alert.name
#       }
#       log_destination_type = "CloudWatchLogs"
#       log_type             = "ALERT"
#     }
#   }
# }

# # CloudWatch Log Group (FLOW)
# resource "aws_cloudwatch_log_group" "anfwlogs_lg_flow" {
#   name              = "lg-anfwlogs-flow-${var.identifier}"
#   retention_in_days = 7
#   kms_key_id        = var.kms_key
# }

# # CloudWatch Log Group (ALERT)
# resource "aws_cloudwatch_log_group" "anfwlogs_lg_alert" {
#   name              = "lg-anfwlogs-alert-${var.identifier}"
#   retention_in_days = 7
#   kms_key_id        = var.kms_key
# }
