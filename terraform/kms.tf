# KMS Key for centralized logging buckets - US West 2
module "centralized_logging_kms_west" {
  # source = "../../../modules/terraform-aws-kms" > If I want to call the mnodule locally
  source = "git::git@github-fd:fvazquez20/awsmodules.git//terraform-aws-kms?ref=main" #  Host alias is github-fd because that’s the one set in the SSH config using key gitfd20

  description             = local.kms_regions["us-west-2"].description
  deletion_window_in_days = local.kms_common_config.deletion_window_in_days
  enable_key_rotation     = local.kms_common_config.enable_key_rotation
  aliases                 = [local.kms_regions["us-west-2"].alias]
  key_owners              = local.kms_common_config.key_owners
  key_users               = local.kms_common_config.key_users
  key_statements          = concat(local.kms_key_statements, [local.kms_guardduty_policy])

  tags = {
    Name        = "Centralized Logging KMS Key West"
    Purpose     = "Encryption for centralized logging buckets"
    Environment = "Audit"
    ManagedBy   = "Terraform"
    Region      = "us-west-2"
  }
}

# KMS Key for centralized logging buckets - US East 2
module "centralized_logging_kms_east" {
  # source = "../../../modules/terraform-aws-kms" > If I want to call the mnodule locally
  source = "git::git@github-fd:fvazquez20/awsmodules.git//terraform-aws-kms?ref=main" #  Host alias is github-fd because that’s the one set in the SSH config using key gitfd20

  providers = {
    aws = aws.aws-use2
  }

  description             = local.kms_regions["us-east-2"].description
  deletion_window_in_days = local.kms_common_config.deletion_window_in_days
  enable_key_rotation     = local.kms_common_config.enable_key_rotation
  aliases                 = [local.kms_regions["us-east-2"].alias]
  key_owners              = local.kms_common_config.key_owners
  key_users               = local.kms_common_config.key_users
  key_statements          = concat(local.kms_key_statements, [local.kms_guardduty_policy])

  tags = {
    Name        = "Centralized Logging KMS Key East"
    Purpose     = "Encryption for centralized logging buckets"
    Environment = "Audit"
    ManagedBy   = "Terraform"
    Region      = "us-east-2"
  }
}
