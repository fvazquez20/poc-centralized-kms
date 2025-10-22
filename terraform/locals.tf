#################################################### IMPORTANT #####################################################
# Utilize this locals block to track all Organization Account IDs and OU IDs.
#
# This allows us to reference all accounts & OUs in an easily identifiable and consistent manner throughout TF.
######################################################################################################################

locals {

  account_map = {
    "organization_management_account" = "112393353424"
    "log_archive_account"             = "814436217830"
    "audit_account"                   = "281053916452"
    "aft_management_account"          = "352647309238"
    "sandbox_account"                 = "700308877444"
  }

  ou_map = {
    "root_ou"     = "r-xdjx"
    "security_ou" = "ou-xdjx-5wunnoev"
    "aft_ou"      = "ou-xdjx-ass7i6ay"
    "sandbox_ou"  = "ou-xdjx-0f94q68n"
  }

  partition = data.aws_partition.current.partition
  region    = data.aws_region.current.id

  # KMS Configuration - Common settings
  kms_common_config = {
    deletion_window_in_days = 7
    enable_key_rotation     = true

    # Key owners — Audit account only (full administrative control)
    key_owners = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    ]

    # Key users — Log Archive account (can use the key, not administer it)
    key_users = [
      "arn:aws:iam::${local.account_map.log_archive_account}:root"
    ]

    # Common tags
    common_tags = {
      Purpose     = "Encryption for centralized logging buckets"
      Environment = "Audit"
      ManagedBy   = "Terraform"
    }
  }

  # KMS Regions configuration
  kms_regions = {
    us-west-2 = {
      description = "KMS key for centralized logging buckets (US West 2)"
      alias       = "centralized-logging-west"
      provider    = "aws"
    }
    us-east-2 = {
      description = "KMS key for centralized logging buckets (US East 2)"
      alias       = "centralized-logging-east"
      provider    = "aws.aws-use2"
    }
  }

  # KMS Key Policy Statements - Common for all regions
  kms_key_statements = [
    # Allow VPC Flow Logs from ANY account in the organization
    {
      sid = "AllowVPCFlowLogsFromAnyAccount"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["delivery.logs.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:SourceOrgID"
          values   = ["o-stz39zbvyh"]
        }
      ]
    },
    # Allow ALB Access Logs from ANY account in the organization
    {
      sid = "AllowALBLogsFromAnyAccount"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:SourceOrgID"
          values   = ["o-stz39zbvyh"]
        }
      ]
    },
    # Allow CloudWatch Logs from ANY account in the organization
    {
      sid = "AllowCloudWatchLogsFromAnyAccount"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["logs.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:SourceOrgID"
          values   = ["o-stz39zbvyh"]
        }
      ]
    },
    # Allow Route 53 Resolver query logging from ANY account in the organization
    {
      sid = "AllowRoute53ResolverFromAnyAccount"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["route53resolver.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:SourceOrgID"
          values   = ["o-stz39zbvyh"]
        }
      ]
    },
    # Allow GuardDuty (org-wide access; tightened per-account below)
    {
      sid = "AllowGuardDutyFromAnyAccount"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["guardduty.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:SourceOrgID"
          values   = ["o-stz39zbvyh"]
        }
      ]
    },
    # Allow AWS Network Firewall from ANY account in the organization
    {
      sid = "AllowNetworkFirewallFromAnyAccount"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["network-firewall.amazonaws.com"]
        }
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:SourceOrgID"
          values   = ["o-stz39zbvyh"]
        }
      ]
    }
  ]

  # Function to generate region-specific GuardDuty policy
  kms_guardduty_policy = {
    sid = "AllowGuardDuty"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    principals = [
      {
        type        = "Service"
        identifiers = ["guardduty.amazonaws.com"]
      }
    ]
    condition = [
      {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      },
      {
        test     = "StringLike"
        variable = "aws:SourceArn"
        values   = ["arn:aws:guardduty:${local.region}:${data.aws_caller_identity.current.account_id}:detector/*"]
      }
    ]
  }
}
