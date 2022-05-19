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
  default     = "traffic-segmentation-with-inspection"
}

# NUMBER OF AVAILABILITY ZONES TO USE
variable "number_azs" {
  type        = number
  description = "Number of Availability Zones to use."
  default     = 1
}