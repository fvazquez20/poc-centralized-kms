# Centralized KMS for AWS Organizations

This project implements centralized KMS (Key Management Service) keys for AWS Organizations to provide encryption for centralized logging buckets across multiple regions.

## Overview

The centralized KMS solution creates and manages KMS keys in multiple AWS regions to support centralized logging infrastructure. These keys are designed to be used by various AWS services across the organization for encrypting log data in centralized logging buckets.

## Architecture

The solution creates KMS keys in two regions:
- **US West 2 (us-west-2)**: Primary region for centralized logging
- **US East 2 (us-east-2)**: Secondary region for centralized logging

## Features

- **Multi-region KMS keys**: Deployed in both US West 2 and US East 2
- **Organization-wide access**: Keys can be used by any account within the AWS Organization
- **Service-specific permissions**: Configured for various AWS services including:
  - VPC Flow Logs
  - Application Load Balancer (ALB) Access Logs
  - CloudWatch Logs
  - Route 53 Resolver Query Logging
  - GuardDuty
  - AWS Network Firewall
- **Automatic key rotation**: Enabled for enhanced security
- **Cross-account access**: Log Archive account can use the keys for encryption
- **Audit account control**: Only the Audit account has administrative control

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.10.5
- AWS Provider >= 5.34.0
- Access to the AWS Organization (Organization ID: o-stz39zbvyh)
- AFT (Account Factory for Terraform) integration

## Configuration

### Key Configuration

The KMS keys are configured with the following settings:

- **Deletion Window**: 7 days
- **Key Rotation**: Enabled
- **Key Owners**: Audit account only (full administrative control)
- **Key Users**: Log Archive account (can use the key, not administer it)

### Supported Services

The KMS keys support encryption for the following AWS services:

1. **VPC Flow Logs** - From any account in the organization
2. **ALB Access Logs** - From any account in the organization  
3. **CloudWatch Logs** - From any account in the organization
4. **Route 53 Resolver** - From any account in the organization
5. **GuardDuty** - From any account in the organization
6. **AWS Network Firewall** - From any account in the organization

### Key Policies

The KMS keys include comprehensive policies that:

- Allow organization-wide access for supported AWS services
- Restrict access to accounts within the AWS Organization
- Provide specific permissions for each service type
- Include conditions to verify the source organization and account

## Deployment

This project is designed to be deployed through AWS Account Factory for Terraform (AFT). The deployment process includes:

1. **Pre-deployment**: Execute pre-api-helpers.sh
2. **Terraform deployment**: Apply the Terraform configuration
3. **Post-deployment**: Execute post-api-helpers.sh

### Manual Deployment

If deploying manually:

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Outputs

The deployment provides the following outputs:

- `centralized_logging_key_arn_west`: ARN of the KMS key in US West 2
- `centralized_logging_key_arn_east`: ARN of the KMS key in US East 2

## Usage

After deployment, the KMS key ARNs can be used in other accounts and services for encryption. The keys are designed to be used with:

- S3 buckets for centralized logging
- CloudWatch Log Groups
- VPC Flow Log destinations
- ALB access log destinations

## Security Considerations

- Keys are managed by the Audit account only
- Cross-account access is restricted to the Log Archive account
- All access is limited to accounts within the AWS Organization
- Service-specific permissions are granted based on AWS service requirements
- Key rotation is enabled for enhanced security

## Monitoring and Compliance

- All key usage is logged in CloudTrail
- Key access is restricted to organization accounts only
- Regular key rotation ensures compliance with security best practices
- Audit account maintains full administrative control

## Troubleshooting

### Common Issues

1. **Access Denied**: Ensure the deploying account has the necessary permissions
2. **Organization ID Mismatch**: Verify the organization ID in the configuration matches your AWS Organization
3. **Cross-account Access**: Ensure the Log Archive account ID is correctly configured

### Support

For issues related to this deployment, check:
- CloudTrail logs for KMS API calls
- IAM permissions for the deploying account
- Organization membership verification

## Contributing

This project follows AWS best practices for KMS key management in multi-account environments. When making changes:

1. Ensure all key policies are properly scoped
2. Test in a non-production environment first
3. Verify organization-wide access requirements
4. Update documentation for any new service support

## License

This project is licensed under the Apache-2.0 License.