<!-- BEGIN_TF_DOCS -->
# AWS Hub and Spoke Architecture with Traffic Segmentation - Terraform

This repository contains terraform code to deploy a sample AWS Hub and Spoke architecture with production and non-production VPCs. In addition, VPC endpoints (SSM and S3) are centralized in a Shared Services VPC, and you can add traffic inspection (in each routing domain, or between routing domains). The following resources are created by default:

- 4 VPCs: 1 Production, 1 Non-Production, 1 Shared Services VPC, and 1 Inspection VPC (two inspect the traffic between routing domains). Following AWS best pratices, VPC flow logs are activated (by default sent to CloudWatch logs). The logs are encrypted at rest with KMS (keys created in the *iam\_kms* module).
  - In the *locals.tf* file you can find the definition of 2 more Spoke VPCs (1 prod and 1 non-prod). If you want to create them, you need to change the **create** variable inside each VPC configuration to *true*.
  - In addition, you can add inspection in each routing domain (prod and non-prod) by setting the *prod* and *non-prod* sub-variables inside the **traffic\_inspection** variable. In the diagram schema below you can see the architecture with all the central VPCs created. The prod and non-prod Inspection VPCs have access to the Internet.
  - VPC Endpoints (ssm, ssmmessages, ec2messages and s3) are deployed in the central Shared Services VPC.
- AWS Transit Gateway, and 4 Transit Gateway Route Tables (prod, non\_prod, shared, and inspection).
  - VPC attachments are associated and propagated to the corresponding TGW Route Table depending the "type" of VPC indicated in the *locals.tf* file.
  - The *inspection\_prod* and *inspection\_non\_prod* Transit Gateway Route Tables are created only if intra-routing domain inspection is created.
  - Propagations and static routes are created accordingly depending the Inspection added in each routing domain.
- EC2 instances in each spoke VPC. To follow best practices, these instances are accessed using AWS Systems Manager - via the VPC endpoints.
- Security Groups for the EC2 instances and VPC endpoints. The configuration can be found in the *locals.tf* file.
- AWS Network Firewall - one per Inspection VPC created (only 1 by default). In the *firewall\_policy.tf* file you can check the different rules configuration per each firewall.
- IAM Roles for CloudWatch access (VPC flow logs) and the SSM/S3 access by the EC2 instances.

The resources deployed and the architectural pattern they follow is purely for demonstration/testing purposes. Take into account that 4 VPCs are created by default trying to not reach the default quota of 5 VPCs per AWS Region. If you have increased your quota and want to add more Spoke or Inspection VPCs in the example, do it in the *locals.tf* file.

## Prerequisites

- An AWS account with an IAM user with the appropriate permissions
- Terraform installed

## Code Principles:

- Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Architecture

![Architecture diagram](./images/traffic\_segmentation\_inspection.png)

## Usage

- Clone the repository
- Edit the *variables.tf* file (in the root directory) to configure the AWS Region to use, the project identifier, and the number of Availability Zones to use. Edit the *locals.tf* (in the root directory) to configure the VPCs to create.
- To change the configuration about the Security Groups and VPC endpoints to create, edit the *locals.tf* file in the project root directory.
- Initialize Terraform using `terraform init`.
- Now you can deploy the rest of the infrastructure using `terraform apply`.
- To delete everything, use `terraform destroy`.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_anfw"></a> [anfw](#module\_anfw) | ./modules/network_firewall | n/a |
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_iam_kms"></a> [iam\_kms](#module\_iam\_kms) | ./modules/iam_kms | n/a |
| <a name="module_phz"></a> [phz](#module\_phz) | ./modules/phz | n/a |
| <a name="module_tgw_route_tables"></a> [tgw\_route\_tables](#module\_tgw\_route\_tables) | ./modules/tgw_route_tables | n/a |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ./modules/vpc_endpoints | n/a |
| <a name="module_vpcs"></a> [vpcs](#module\_vpcs) | aws-ia/vpc/aws | >= 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_networkfirewall_firewall_policy.anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_firewall_policy.anfw_policy_non_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_firewall_policy.anfw_policy_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_icmp_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to create the environment. | `string` | `"us-west-2"` | no |
| <a name="input_logging_destination"></a> [logging\_destination](#input\_logging\_destination) | LOGGING DESTINATION FOR VPC FLOW LOGS AND AWS NETWORK FIREWALL (CloudWatch Logs by default) | <pre>object({<br>    vpc_flow_logs    = optional(string) # Options: "cloud-watch-logs", "s3", "none"<br>    network_firewall = optional(string) # Options: "cloud-watch-logs", "s3", "kinesis-firehose", "none"<br>  })</pre> | <pre>{<br>  "network_firewall": "cloud-watch-logs",<br>  "vpc_flow_logs": "cloud-watch-logs"<br>}</pre> | no |
| <a name="input_number_azs"></a> [number\_azs](#input\_number\_azs) | Number of Availability Zones to use. | `number` | `2` | no |
| <a name="input_project_identifier"></a> [project\_identifier](#input\_project\_identifier) | Project Name, used as identifer when creating resources. | `string` | `"traffic-segmentation-with-inspection"` | no |
| <a name="input_traffic_inspection"></a> [traffic\_inspection](#input\_traffic\_inspection) | ENABLING TRAFFIC INSPECTION OR NOT IN THE ENVIRONMENT (Enabled between segments by default) | <pre>object({<br>    prod          = optional(bool)<br>    non-prod      = optional(bool)<br>    cross-domains = optional(bool)<br>  })</pre> | <pre>{<br>  "cross-domains": true,<br>  "non-prod": true,<br>  "prod": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instances"></a> [ec2\_instances](#output\_ec2\_instances) | ID of the EC2 instances created. |
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | ARN of the Network Firewall resources created. |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | Transit Gateway ID. |
| <a name="output_transit_gateway_route_tables"></a> [transit\_gateway\_route\_tables](#output\_transit\_gateway\_route\_tables) | TGW Route Tables ID created. |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | ID of the VPC endpoints created. |
| <a name="output_vpcs_id"></a> [vpcs\_id](#output\_vpcs\_id) | VPCs created. |
<!-- END_TF_DOCS -->