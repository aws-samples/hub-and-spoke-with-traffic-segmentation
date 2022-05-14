# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# VPCs to create - Terraform module used can be found here: https://github.com/aws-ia/terraform-aws-vpc 
module "vpcs" {
  for_each = var.vpc_info
  source   = "aws-ia/vpc/aws"
  version  = ">= 1.0.0"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = var.number_azs

  subnets = {
    private = {
      name_prefix  = "private"
      cidrs        = slice(each.value.private_subnets, 0, var.number_azs)
      route_to_nat = false
    }
    transit_gateway = {
      name_prefix                                     = "tgw"
      cidrs                                           = slice(each.value.tgw_subnets, 0, var.number_azs)
      transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  vpc_flow_logs = {
    log_destination_type = each.value.flow_log_config.log_destination_type
    retention_in_days    = each.value.flow_log_config.retention_in_days
    iam_role_arn         = module.iam_kms.vpc_flowlog_role
    kms_key_id           = module.iam_kms.kms_arn
  }
}

# TRANSIT GATEWAY
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit-Gateway-${var.project_identifier}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "transit-gateway-${var.project_identifier}"
  }
}

# TRANSIT GATEWAY ROUTE TABLES, PROPAGATIONS AND ASSOCIATIONS
module "tgw_route_tables" {
  source = "./modules/tgw_route_tables"

  identifier          = var.project_identifier
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id
  vpc_tgw_attachments = { for k, v in module.vpcs : k => v.transit_gateway_attachment_id }
  vpc_types           = { for k, v in var.vpc_info : k => v.type }
}

# VPC ROUTES TO THE TRANSIT GATEWAY (to remove once the VPC MODULE has this feature ready)
module "vpc_route_to_tgw" {
  source   = "./modules/vpc_route_to_tgw"
  for_each = module.vpcs

  number_azs         = var.number_azs
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  route_tables       = values({ for k, v in each.value.route_table_by_subnet_type.private : k => v.route_table_id })
}

# VPC ENDPOINTS
module "vpc_endpoints" {
  for_each = module.vpcs
  source   = "./modules/vpc_endpoints"

  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  endpoints_security_group = local.security_groups.endpoints
  endpoints_service_names  = local.endpoints_service_names
}

# EC2 INSTANCES
module "compute" {
  for_each = module.vpcs
  source   = "./modules/compute"

  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  number_azs               = var.number_azs
  instance_type            = var.vpc_info[each.key].instance_type
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.instance
}

# IAM ROLES
module "iam_kms" {
  source = "./modules/iam_kms"

  identifier = var.project_identifier
  aws_region = var.aws_region
}