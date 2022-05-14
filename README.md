<!-- BEGIN_TF_DOCS -->
# AWS Hub and Spoke Architecture with Traffic Segmentation - Terraform

This repository contains terraform code to deploy a sample AWS Hub and Spoke architecture with production and non-production VPCs, so you can see how traffic segmentation is achieved using several Transit Gateway Route Tables. The following resources are created by default:

- 4 VPCs: 2 Production and 2 Non-Production. Following AWS best pratices, VPC flow logs are activated (by default sent to CloudWatch logs). The logs are encrypted at rest with KMS (keys created in the *iam\_kms* module).
- AWS Transit Gateway, and 2 Transit Gateway Route Tables (prod and non\_prod). VPC attachments are associated and propagated to the corresponding TGW Route Table depending the "type" of VPC indicated in the *variables.tf* file.
- VPC Endpoints (ssm, ssmmessages, ec2messages and s3) deployed in each VPC - endpoints decentralized.
- EC2 instances. To follow best practices, these instances are accessed using AWS Systems Manager - via the VPC endpoints.
- Security Groups for the EC2 instances and VPC endpoints. The configuration of the SGs can be found in the *locals.tf* file.
- IAM Roles for CloudWatch access (VPC flow logs) and the SSM/S3 access by the EC2 instances.

The resources deployed and the architectural pattern they follow is purely for demonstration/testing purposes.

## Prerequisites

- An AWS account with an IAM user with the appropriate permissions
- Terraform installed

## Code Principles:

- Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Architecture

![Architecture diagram](./images/traffic\_segmentation.png)

## Usage

- Clone the repository
- Edit the *variables.tf* file in the project root directory. This file contains the variables that are used to configure the VPCs to create.
- To change the configuration about the Security Groups and VPC endpoints to create, edit the *locals.tf* file in the project root directory.
- Initialize Terraform using `terraform init`.
- To start deploying the infrastructure, you need to create the VPCs before any other resource (due to some dependency constraint in other module). For that reason use `terraform apply -target="module.vpc_module"`.
- Now you can deploy the rest of the infrastructure using `terraform apply`.

**Note** The default number of Availability Zones to use in the VPCs is 1. To follow best practices, each resource - EC2 instance, and VPC endpoints - will be created in each Availability Zone. **Keep this in mind** to avoid extra costs unless you are happy to deploy more resources and accept additional costs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_iam_kms"></a> [iam\_kms](#module\_iam\_kms) | ./modules/iam_kms | n/a |
| <a name="module_tgw_vpc_routes"></a> [tgw\_vpc\_routes](#module\_tgw\_vpc\_routes) | ./modules/tgw_vpc_routes | n/a |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ./modules/vpc_endpoints | n/a |
| <a name="module_vpc_module"></a> [vpc\_module](#module\_vpc\_module) | aws-ia/vpc/aws | >= 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route_table.non_prod_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.prod_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.non_prod_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.prod_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.non_prod_propagation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.prod_propagation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to create the environment. | `string` | `"us-west-2"` | no |
| <a name="input_number_azs"></a> [number\_azs](#input\_number\_azs) | Number of Availability Zones to use. | `number` | `1` | no |
| <a name="input_project_identifier"></a> [project\_identifier](#input\_project\_identifier) | Project Name, used as identifer when creating resources. | `string` | `"hub-spoke-traffic-segmentation"` | no |
| <a name="input_vpc_info"></a> [vpc\_info](#input\_vpc\_info) | Information about the VPCs to create. | `map(any)` | <pre>{<br>  "vpc1": {<br>    "cidr_block": "10.0.0.0/24",<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "private_subnets": [<br>      "10.0.0.0/26",<br>      "10.0.0.64/26",<br>      "10.0.0.128/26"<br>    ],<br>    "tgw_subnets": [<br>      "10.0.0.192/28",<br>      "10.0.0.208/28",<br>      "10.0.0.224/28"<br>    ],<br>    "type": "prod"<br>  },<br>  "vpc2": {<br>    "cidr_block": "10.0.1.0/24",<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "private_subnets": [<br>      "10.0.1.0/26",<br>      "10.0.1.64/26",<br>      "10.0.1.128/26"<br>    ],<br>    "tgw_subnets": [<br>      "10.0.1.192/28",<br>      "10.0.1.208/28",<br>      "10.0.1.224/28"<br>    ],<br>    "type": "prod"<br>  },<br>  "vpc3": {<br>    "cidr_block": "10.0.2.0/24",<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "private_subnets": [<br>      "10.0.2.0/26",<br>      "10.0.2.64/26",<br>      "10.0.2.128/26"<br>    ],<br>    "tgw_subnets": [<br>      "10.0.2.192/28",<br>      "10.0.2.208/28",<br>      "10.0.2.224/28"<br>    ],<br>    "type": "non-prod"<br>  },<br>  "vpc4": {<br>    "cidr_block": "10.0.3.0/24",<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "private_subnets": [<br>      "10.0.3.0/26",<br>      "10.0.3.64/26",<br>      "10.0.3.128/26"<br>    ],<br>    "tgw_subnets": [<br>      "10.0.3.192/28",<br>      "10.0.3.208/28",<br>      "10.0.3.224/28"<br>    ],<br>    "type": "non-prod"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instances"></a> [ec2\_instances](#output\_ec2\_instances) | Information about the EC2 instances created. |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | Transit Gateway ID. |
| <a name="output_transit_gateway_non_production_rtb"></a> [transit\_gateway\_non\_production\_rtb](#output\_transit\_gateway\_non\_production\_rtb) | Transit Gateway Route Table ID - Non-Production. |
| <a name="output_transit_gateway_production_rtb"></a> [transit\_gateway\_production\_rtb](#output\_transit\_gateway\_production\_rtb) | Transit Gateway Route Table ID - Production. |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | Information about the VPC endpoints created. |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | VPCs created. |
<!-- END_TF_DOCS -->