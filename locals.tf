# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/locals.tf ---

locals {

  # VPCs TO CREATE
  vpcs = {
    vpc1 = {
      type          = "prod"
      cidr_block    = "10.0.0.0/24"
      instance_type = "t2.micro"

      subnets = {
        private = {
          name_prefix              = "private"
          cidrs                    = slice(["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"], 0, var.number_azs)
          route_to_nat             = false
          route_to_transit_gateway = ["0.0.0.0/0"]
        }
        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.0.0.192/28", "10.0.0.208/28", "10.0.0.224/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = var.logging_destination.vpc_flow_logs
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }

      creation = true
    }

    vpc2 = {
      type          = "prod"
      cidr_block    = "10.0.1.0/24"
      instance_type = "t2.micro"

      subnets = {
        private = {
          name_prefix              = "private"
          cidrs                    = slice(["10.0.1.0/26", "10.0.1.64/26", "10.0.1.128/26"], 0, var.number_azs)
          route_to_nat             = false
          route_to_transit_gateway = ["0.0.0.0/0"]
        }

        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.0.1.192/28", "10.0.1.208/28", "10.0.1.224/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = var.logging_destination.vpc_flow_logs
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }

      creation = false
    }

    vpc3 = {
      type          = "non-prod"
      cidr_block    = "10.1.0.0/24"
      instance_type = "t2.micro"

      subnets = {
        private = {
          name_prefix              = "private"
          cidrs                    = slice(["10.1.0.0/26", "10.1.0.64/26", "10.1.0.128/26"], 0, var.number_azs)
          route_to_nat             = false
          route_to_transit_gateway = ["0.0.0.0/0"]
        }
        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.1.0.192/28", "10.1.0.208/28", "10.1.0.224/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = var.logging_destination.vpc_flow_logs
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }

      creation = true
    }

    vpc4 = {
      type          = "non-prod"
      cidr_block    = "10.1.1.0/24"
      instance_type = "t2.micro"

      subnets = {
        private = {
          name_prefix              = "private"
          cidrs                    = slice(["10.1.1.0/26", "10.1.1.64/26", "10.1.1.128/26"], 0, var.number_azs)
          route_to_nat             = false
          route_to_transit_gateway = ["0.0.0.0/0"]
        }
        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.1.1.192/28", "10.1.1.208/28", "10.1.1.224/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = var.logging_destination.vpc_flow_logs
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }

      creation = false
    }

    inspection-prod = {
      type            = "inspection-prod"
      cidr_block      = "10.10.0.0/24"
      firewall_policy = aws_networkfirewall_firewall_policy.anfw_policy_prod.arn

      subnets = {
        public = {
          name_prefix               = "public"
          cidrs                     = slice(["10.10.0.0/28", "10.10.0.16/28", "10.10.0.32/28"], 0, var.number_azs)
          nat_gateway_configuration = "all_azs"
        }
        private = {
          name_prefix              = "inspection"
          cidrs                    = slice(["10.10.0.48/28", "10.10.0.64/28", "10.10.0.80/28"], 0, var.number_azs)
          route_to_nat             = true
          route_to_transit_gateway = [local.cidr_blocks.prod]
        }
        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.10.0.96/28", "10.10.0.112/28", "10.10.0.128/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = var.logging_destination.vpc_flow_logs
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }
      network_firewall_logs = var.logging_destination.network_firewall

      creation = var.traffic_inspection.prod
    }

    inspection-non-prod = {
      type            = "inspection-non-prod"
      cidr_block      = "10.20.0.0/24"
      firewall_policy = aws_networkfirewall_firewall_policy.anfw_policy_non_prod.arn

      subnets = {
        public = {
          name_prefix               = "public"
          cidrs                     = slice(["10.20.0.0/28", "10.20.0.16/28", "10.20.0.32/28"], 0, var.number_azs)
          nat_gateway_configuration = "all_azs"
        }
        private = {
          name_prefix              = "inspection"
          cidrs                    = slice(["10.20.0.48/28", "10.20.0.64/28", "10.20.0.80/28"], 0, var.number_azs)
          route_to_nat             = true
          route_to_transit_gateway = [local.cidr_blocks.non_prod]
        }
        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.20.0.96/28", "10.20.0.112/28", "10.20.0.128/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }
      network_firewall_logs = var.logging_destination.network_firewall

      creation = var.traffic_inspection.non-prod
    }

    inspection = {
      type            = "inspection"
      cidr_block      = "10.30.0.0/24"
      firewall_policy = aws_networkfirewall_firewall_policy.anfw_policy.arn

      subnets = {
        private = {
          name_prefix              = "inspection"
          cidrs                    = slice(["10.30.0.48/28", "10.30.0.64/28", "10.30.0.80/28"], 0, var.number_azs)
          route_to_nat             = false
          route_to_transit_gateway = [local.cidr_blocks.region]
        }
        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.30.0.96/28", "10.30.0.112/28", "10.30.0.128/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }
      network_firewall_logs = var.logging_destination.network_firewall

      creation = var.traffic_inspection.cross-domains
    }

    shared-services = {
      type       = "shared-services"
      cidr_block = "10.40.0.0/24"

      subnets = {
        private = {
          name_prefix              = "private"
          cidrs                    = slice(["10.40.0.0/26", "10.40.0.64/26", "10.40.0.128/26"], 0, var.number_azs)
          route_to_nat             = false
          route_to_transit_gateway = ["0.0.0.0/0"]
        }
        transit_gateway = {
          name_prefix                                     = "tgw"
          cidrs                                           = slice(["10.40.0.192/28", "10.40.0.208/28", "10.40.0.224/28"], 0, var.number_azs)
          transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
          transit_gateway_default_route_table_association = false
          transit_gateway_default_route_table_propagation = false
        }
      }

      vpc_flow_logs = {
        log_destination_type = "cloud-watch-logs" # Options: "cloud-watch-logs", "s3", "none"
        retention_in_days    = 7
        iam_role_arn         = module.iam_kms.vpc_flowlog_role
        kms_key_id           = module.iam_kms.kms_arn
      }

      creation = true
    }
  }

  # CIDR BLOCKS TO USE IN THE TGW ROUTES
  cidr_blocks = {
    prod     = "10.0.0.0/16"
    non_prod = "10.1.0.0/16"
    region   = "10.0.0.0/8"
  }

  # INFORMATION ABOUT THE DIFFERENT SECURITY GROUPS TO CREATE (DEPENDING THE RESOURCE)
  security_groups = {
    instance = {
      name        = "instance_sg"
      description = "Security Group used in the instances"
      ingress = {
        icmp = {
          description = "Allowing ICMP traffic"
          from        = -1
          to          = -1
          protocol    = "icmp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        http = {
          description = "Allowing HTTP traffic"
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
      egress = {
        any = {
          description = "Any traffic"
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    endpoints = {
      name        = "endpoints_sg"
      description = "Security Group for SSM connection"
      ingress = {
        https = {
          description = "Allowing HTTPS"
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
      egress = {
        any = {
          description = "Any traffic"
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  # VPC ENDPOINT INFORMATION
  endpoints_service_names = {
    ssm = {
      name           = "com.amazonaws.${var.aws_region}.ssm"
      type           = "Interface"
      private_dns    = true
      phz_name       = "ssm.${var.aws_region}.amazonaws.com"
      phz_multialias = false
    }
    ssmmessages = {
      name           = "com.amazonaws.${var.aws_region}.ssmmessages"
      type           = "Interface"
      private_dns    = true
      phz_name       = "ssmmessages.${var.aws_region}.amazonaws.com"
      phz_multialias = false
    }
    ec2messages = {
      name           = "com.amazonaws.${var.aws_region}.ec2messages"
      type           = "Interface"
      private_dns    = true
      phz_name       = "ec2messages.${var.aws_region}.amazonaws.com"
      phz_multialias = false
    }
    s3 = {
      name           = "com.amazonaws.${var.aws_region}.s3"
      type           = "Interface"
      private_dns    = false
      phz_name       = "s3.${var.aws_region}.amazonaws.com"
      phz_multialias = true
    }
  }
}
