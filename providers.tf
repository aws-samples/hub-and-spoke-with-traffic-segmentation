# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/providers.tf ---

terraform {
  required_version = "= 1.2.7"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.73.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.15.0"
    }
  }

}

# AWS Provider configuration - AWS Region indicated in root/variables.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "Hub and Spoke - Traffic Segmentation"
      Terraform = "Managed"
      Region    = var.aws_region
    }
  }
}
provider "awscc" {
  region = var.aws_region
}