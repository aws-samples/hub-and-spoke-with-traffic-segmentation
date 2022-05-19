# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/network_firewall/outputs.tf ---

output "network_firewall" {
  value       = aws_networkfirewall_firewall.anfw
  description = "AWS Network Firewall Resource."
}