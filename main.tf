# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# VPCs to create - Terraform module used can be found here: https://github.com/aws-ia/terraform-aws-vpc 
module "vpcs" {
  for_each = {
    for k, v in local.vpcs : k => v
    if v.creation
  }
  source  = "aws-ia/vpc/aws"
  version = "= 1.4.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = var.number_azs

  subnets       = each.value.subnets
  vpc_flow_logs = each.value.vpc_flow_logs
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

  identifier         = var.project_identifier
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  vpc_tgw_attachments = { for k, v in module.vpcs : k => v.transit_gateway_attachment_id }
  vpc_types           = { for k, v in local.vpcs : k => v.type }
  segment_cidr_blocks = local.cidr_blocks

  traffic_inspection = var.traffic_inspection
}

# VPC ENDPOINTS (In Shared Services VPC)
module "vpc_endpoints" {
  for_each = {
    for k, v in module.vpcs : k => v
    if local.vpcs[k].type == "shared-services"
  }
  source = "./modules/vpc_endpoints"

  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  endpoints_security_group = local.security_groups.endpoints
  endpoints_service_names  = local.endpoints_service_names
}

# PRIVATE HOSTED ZONES (In Prod and Non-Prod VPCs)
module "phz" {
  source                 = "./modules/phz"
  vpc_ids                = { for k, v in module.vpcs : k => v.vpc_attributes.id if local.vpcs[k].type == "prod" || local.vpcs[k].type == "non-prod" }
  endpoint_dns           = module.vpc_endpoints["shared-services"].endpoints_dns
  endpoint_service_names = local.endpoints_service_names
}

# EC2 INSTANCES (In Prod and Non-Prod VPCs)
module "compute" {
  for_each = {
    for k, v in module.vpcs : k => v
    if local.vpcs[k].type == "prod" || local.vpcs[k].type == "non-prod"
  }
  source = "./modules/compute"

  identifier               = var.project_identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  number_azs               = var.number_azs
  instance_type            = local.vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.instance
}

# NETWORK FIREWALL RESOURCES
module "anfw" {
  for_each = {
    for k, v in module.vpcs : k => v
    if local.vpcs[k].type == "inspection-prod" || local.vpcs[k].type == "inspection-non-prod" || local.vpcs[k].type == "inspection" 
  }
  source = "./modules/network_firewall"

  identifier        = var.project_identifier
  vpc_name          = each.key
  vpc_info          = each.value
  firewall_policy   = local.vpcs[each.key].firewall_policy
  route_to_endpoint = local.vpcs[each.key].subnets.private.route_to_transit_gateway[0]
  number_azs = var.number_azs
  logging_config = var.logging_destination.network_firewall
  kms_key = module.iam_kms.kms_arn

  depends_on = [ module.vpcs ]
}

# IAM ROLES
module "iam_kms" {
  source = "./modules/iam_kms"

  identifier = var.project_identifier
  aws_region = var.aws_region
}