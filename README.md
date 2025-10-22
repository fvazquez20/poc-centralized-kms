# POC PagerDuty Notifications - AWS Security Monitoring

This project implements automated PagerDuty notifications for AWS security services, providing real-time alerting for critical security findings and health events across your AWS organization.

## Overview

This project assumes that **GuardDuty** and **Security Hub** are already deployed and configured in your AWS organization. It focuses solely on setting up the notification infrastructure to send alerts to PagerDuty when critical findings are detected.

## Architecture

The project creates:
- **SNS Topics** for each notification type (GuardDuty, Security Hub, Health Dashboard)
- **EventBridge Rules** to capture specific events from AWS services
- **IAM Roles** for EventBridge to publish to SNS
- **PagerDuty Integration** via webhook endpoints

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.6.0
- Git
- **GuardDuty** already deployed and configured in your organization
- **Security Hub** already deployed and configured in your organization
- PagerDuty account with integration keys

## Modules Used

This project uses custom AWS modules from the GitHub repository:
- `terraform-aws-modules/sns/aws`
- `terraform-aws-modules/eventbridge/aws`
- `terraform-aws-modules/iam/aws`

## Configuration

### Notification Types

The project configures notifications for:

1. **GuardDuty Critical Findings**
   - Severity levels: 9.0 - 10.0
   - Source: `aws.guardduty`
   - Detail type: `GuardDuty Finding`

2. **Security Hub Critical/High Findings**
   - Severity levels: CRITICAL, HIGH
   - Source: `aws.securityhub`
   - Detail type: `Security Hub Findings - Imported`

3. **AWS Health Dashboard Events**
   - Event types: issue, scheduledChange
   - Source: `aws.health`
   - Detail type: `AWS Health Event`

### Account Configuration

The project is configured for the following AWS accounts:
- Organization Management Account: `112393353424`
- Log Archive Account: `814436217830`
- Audit Account: `281053916452`
- AFT Management Account: `352647309238`
- Sandbox Account: `700308877444`

## Quick Start

### 1. Clone the Repository

```bash
git clone git@github.com:fvazquez20/awsmodules.git
cd poc-pagerduty-notifications
```

### 2. Configure PagerDuty Integration Keys

Update the PagerDuty integration keys in `locals.tf`:

```hcl
pagerduty_endpoint = "https://events.pagerduty.com/integration/YOUR_INTEGRATION_KEY/enqueue"
```

Replace `YOUR_INTEGRATION_KEY` with your actual PagerDuty integration keys for each service.

### 3. Configure AWS Credentials

Ensure you have AWS credentials configured for the audit account:

```bash
aws configure --profile audit-account
```

### 4. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

## Features

- **Multi-Service Monitoring**: Integrates with GuardDuty, Security Hub, and AWS Health
- **Severity-Based Filtering**: Only sends notifications for critical and high-severity findings
- **Regional Support**: Configurable for multiple AWS regions
- **Modular Design**: Reusable Terraform modules from GitHub
- **IAM Security**: Proper IAM roles and policies for secure communication
- **EventBridge Integration**: Efficient event routing and filtering

## Environment Variables

Set the following environment variables before deployment:

```bash
export AWS_PROFILE=audit-account
export AWS_REGION=us-west-2  # or your preferred region
```

## Customization

### Adding New Notification Types

To add new notification types, update the `notification_configs` in `locals.tf`:

```hcl
notification_configs = {
  "your-new-notification-type" = {
    sns_name = "your-sns-topic-name"
    rule_name = "your-eventbridge-rule-name"
    role_name = "your-iam-role-name"
    pagerduty_endpoint = "https://events.pagerduty.com/integration/YOUR_KEY/enqueue"
    event_pattern = {
      "source" = ["aws.your-service"]
      "detail-type" = ["Your Event Type"]
      "detail" = {
        "your-filter" = ["your-values"]
      }
    }
  }
}
```

### Modifying Severity Levels

Update the severity filters in the event patterns:

```hcl
# For GuardDuty
"detail" = {
  "severity" = [8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 9.0, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 10.0]
}

# For Security Hub
"detail" = {
  "findings" = {
    "Severity" = {
      "Label" = ["CRITICAL", "HIGH", "MEDIUM"]
    }
  }
}
```

## Testing

### Test SNS Topics

```bash
# Test SNS topic directly
aws sns publish \
  --topic-arn "arn:aws:sns:us-west-2:ACCOUNT:guardduty-critical-findings" \
  --message "Test message" \
  --profile audit-account
```

### Test EventBridge Rules

```bash
# Test EventBridge rule
aws events test-event-pattern \
  --event-pattern '{"source":["aws.guardduty"],"detail-type":["GuardDuty Finding"]}' \
  --event '{"source":"aws.guardduty","detail-type":"GuardDuty Finding","detail":{"severity":9.5}}' \
  --profile audit-account
```

## Monitoring

### CloudWatch Logs

Monitor EventBridge and SNS activity through CloudWatch Logs:
- EventBridge execution logs
- SNS delivery status
- PagerDuty webhook responses

### PagerDuty Dashboard

Check your PagerDuty dashboard for:
- Incident creation
- Alert frequency
- Integration health

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Note**: This will remove all notification infrastructure but will not affect the underlying GuardDuty or Security Hub deployments.

## Troubleshooting

### Common Issues

1. **PagerDuty Integration Keys**: Ensure integration keys are correctly configured
2. **IAM Permissions**: Verify EventBridge has permission to publish to SNS
3. **Event Patterns**: Check that event patterns match the actual AWS service events
4. **SNS Delivery**: Monitor SNS delivery status in CloudWatch

### Useful Commands

```bash
# Check EventBridge rules
aws events list-rules --profile audit-account

# Check SNS topics
aws sns list-topics --profile audit-account

# Check IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `eb-`)]' --profile audit-account
```

## Security Considerations

- **Integration Keys**: Store PagerDuty integration keys securely
- **IAM Roles**: Follow principle of least privilege
- **Encryption**: Consider enabling SNS encryption for sensitive notifications
- **Access Logging**: Enable CloudTrail for audit purposes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues, please:
1. Check the troubleshooting section
2. Review AWS EventBridge and SNS documentation
3. Check PagerDuty integration documentation
4. Create an issue in the repository

## Changelog

### v1.0.0
- Initial release
- GuardDuty critical findings notifications
- Security Hub critical/high findings notifications
- AWS Health Dashboard notifications
- EventBridge and SNS integration
- PagerDuty webhook integration
