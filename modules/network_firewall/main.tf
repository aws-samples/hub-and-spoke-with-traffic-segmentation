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
# TGW Subnet Route Tables
resource "awscc_ec2_route_table" "tgw_route_table" {
  count = var.number_azs

  vpc_id = var.vpc_info.vpc_attributes.id

  tags = concat([{ "key" = "Name", "value" = "tgw-${local.availability_zones[count.index]}" }])
}

# TGW Route Table - Subnet Association
resource "awscc_ec2_subnet_route_table_association" "tgw_route_table_association" {
  count = var.number_azs

  route_table_id = awscc_ec2_route_table.tgw_route_table[count.index].id
  subnet_id      = var.vpc_info.tgw_subnet_attributes_by_az[local.availability_zones[count.index]].id
}

# Route from the TGW Subnet to 0.0.0.0/0 via the firewall endpoint
resource "aws_route" "tgw_to_firewall_endpoint" {
  count = var.number_azs

  route_table_id = awscc_ec2_route_table.tgw_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id = { for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id }[local.availability_zones[count.index]]
}

# Route from the Public Subnet to the Segment CIDR block via the firewall endpoint
resource "aws_route" "public_to_firewall_endpoint" {
  count = var.vpc_name != "inspection" ? var.number_azs : 0

  route_table_id = var.vpc_info.route_table_by_subnet_type.public[local.availability_zones[count.index]].id
  destination_cidr_block = var.route_to_endpoint
  vpc_endpoint_id = { for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id }[local.availability_zones[count.index]]
}

# LOGGING
# Logging Configuration
resource "aws_networkfirewall_logging_configuration" "anfw_logs" {
  firewall_arn = aws_networkfirewall_firewall.anfw.arn
  logging_configuration {

    log_destination_config {
      log_destination = local.log_destination.flow[var.logging_config]
      log_destination_type = local.log_destination_type[var.logging_config]
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = local.log_destination.alert[var.logging_config]
      log_destination_type = local.log_destination_type[var.logging_config]
      log_type             = "ALERT"
    }
  }
}

# CLOUDWATCH LOGS (if applicable)
# CloudWatch Log Group (FLOW)
resource "aws_cloudwatch_log_group" "anfwlogs_lg_flow" {
  count = var.logging_config == "cloud-watch-logs" ? 1 : 0

  name              = "lg-anfwlogs-flow-${var.vpc_name}-${var.identifier}"
  retention_in_days = 7
  kms_key_id        = var.kms_key
}

# CloudWatch Log Group (ALERT)
resource "aws_cloudwatch_log_group" "anfwlogs_lg_alert" {
  count = var.logging_config == "cloud-watch-logs" ? 1 : 0

  name              = "lg-anfwlogs-alert-${var.vpc_name}-${var.identifier}"
  retention_in_days = 7
  kms_key_id        = var.kms_key
}

# S3 BUCKET (if applicable)
# Bucket
resource "aws_s3_bucket" "s3_bucket" {
  count = var.logging_config == "s3" ? 1 : 0

  bucket = "anfw-logs-${var.vpc_name}-${var.identifier}"

  lifecycle {
    ignore_changes = [server_side_encryption_configuration]
  }
}

# Encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  count = var.logging_config == "s3" ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key
      sse_algorithm     = "aws:kms"
    }
  }
}





