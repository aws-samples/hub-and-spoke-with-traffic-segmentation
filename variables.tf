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
  default     = 2
}

# LOGGING DESTINATION FOR VPC FLOW LOGS AND AWS NETWORK FIREWALL (CloudWatch Logs by default)
variable "logging_destination" {
  description = "Logging destination for VPC Flow Logs and AWS Network Firewall (CloudWatch Logs by default)."
  type = object({
    vpc_flow_logs    = optional(string) # Options: "cloud-watch-logs", "s3", "none"
    network_firewall = optional(string) # Options: "cloud-watch-logs", "s3", "kinesis-firehose", "none"
  })

  default = {
    vpc_flow_logs    = "cloud-watch-logs"
    network_firewall = "cloud-watch-logs"
  }
}

# ENABLING TRAFFIC INSPECTION OR NOT IN THE ENVIRONMENT (Enabled between segments by default)
variable "traffic_inspection" {
  description = "Enabling traffic inspection (enabled between routing domains by default)."
  type = object({
    prod          = optional(bool)
    non-prod      = optional(bool)
    cross-domains = optional(bool)
  })

  default = {
    prod          = false
    non-prod      = false
    cross-domains = true
  }
}