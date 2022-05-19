# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/variables.tf ---

# AWS REGION
variable "aws_region" {
  type        = string
  description = "AWS Region to create the environment."
  default     = "us-west-2"
}

# PROJECT IDENTIFIER
variable "project_identifier" {
  type        = string
  description = "Project Name, used as identifer when creating resources."
  default     = "hub-spoke-traffic-segmentation"
}

# NUMBER OF AVAILABILITY ZONES TO USE
variable "number_azs" {
  type        = number
  description = "Number of Availability Zones to use."
  default     = 1
}

# VPC INFORMATION
variable "vpc_info" {
  type        = map(any)
  description = "Information about the VPCs to create."
  default = {
    "vpc1" = {
      type            = "prod"
      cidr_block      = "10.0.0.0/24"
      private_subnets = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]
      tgw_subnets     = ["10.0.0.192/28", "10.0.0.208/28", "10.0.0.224/28"]
      instance_type   = "t2.micro"
      flow_log_config = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
      }
    }
    "vpc2" = {
      type            = "prod"
      cidr_block      = "10.0.1.0/24"
      private_subnets = ["10.0.1.0/26", "10.0.1.64/26", "10.0.1.128/26"]
      tgw_subnets     = ["10.0.1.192/28", "10.0.1.208/28", "10.0.1.224/28"]
      instance_type   = "t2.micro"
      flow_log_config = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
      }
    }
    "vpc3" = {
      type            = "non-prod"
      cidr_block      = "10.1.0.0/24"
      private_subnets = ["10.1.0.0/26", "10.1.0.64/26", "10.1.0.128/26"]
      tgw_subnets     = ["10.1.0.192/28", "10.1.0.208/28", "10.1.0.224/28"]
      instance_type   = "t2.micro"
      flow_log_config = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
      }
    }
    "vpc4" = {
      type            = "non-prod"
      cidr_block      = "10.1.1.0/24"
      private_subnets = ["10.1.1.0/26", "10.1.1.64/26", "10.1.1.128/26"]
      tgw_subnets     = ["10.1.1.192/28", "10.1.1.208/28", "10.1.1.224/28"]
      instance_type   = "t2.micro"
      flow_log_config = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
      }
    }
  }
}