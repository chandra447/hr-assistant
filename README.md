# HR Assistant Bedrock Agent Implementation using Bedrock-Forge

## Overview

This project implements an HR assistant Bedrock Agent using the bedrock-forge tool, designed to simplify and accelerate the deployment of AWS Bedrock agents. The implementation is based on the AWS Bedrock sample for "Create Agent with Function Definition" but uses a YAML-driven, declarative approach through bedrock-forge.

## What Has Been Implemented

### 1. HR Assistant Agent (`hr-agent.yml`)

- **Foundation Model**: `mistral.mistral-7b-instruct-v0:2`
- **Primary Function**: Help employees manage vacation time and HR policies
- **Capabilities**:
  - Check available vacation days for employees
  - Book vacation requests
  - Answer general HR policy questions
- **Action Groups**: Configured with vacation management functions
- **IAM Role**: Auto-generated with necessary permissions

### 2. Lambda Function (`hr-lambda.yml`)

- **Runtime**: Python 3.9
- **Purpose**: Backend logic for HR operations
- **Functions**:
  - `get_available_vacation_days`: Retrieves available vacation days for an employee
  - `book_vacation`: Processes vacation booking requests
- **Database**: Uses SQLite for employee and vacation data management
- **IAM Role**: Auto-generated with Lambda execution permissions

### 3. Lambda Function Code (`lambda-functions/hr-lambda/lambda_function.py`)

- Implements the core HR business logic
- Handles database operations for employee vacation management
- Provides structured responses for the Bedrock agent

### 4. CI/CD Workflows

- **Validation Workflow** (`.github/workflows/validate-bedrock.yml`):
  - Validates YAML configurations on pull requests
  - Generates Terraform files for review
  - Provides feedback through PR comments
  
- **Deployment Workflow** (`.github/workflows/deploy-bedrock.yml`):
  - Deploys to development environment first
  - Requires approval for production deployment
  - Uses Terraform for infrastructure management

## How Bedrock-Forge Implements Deployment

### 1. YAML to Terraform Conversion

Bedrock-forge converts your YAML configurations into Terraform modules:

```bash
bedrock-forge generate
```

This command:
- Parses your YAML files
- Validates cross-references between resources
- Generates Terraform files in the `outputs_tf` directory
- Creates proper dependency management between resources

### 2. Automatic IAM Management

Bedrock-forge automatically generates:
- **Agent Execution Roles**: With permissions for Bedrock model invocation and Lambda execution
- **Lambda Execution Roles**: With CloudWatch logging and required service permissions
- **Resource Policies**: Allowing agents to invoke Lambda functions

### 3. Deployment Pipeline

1. **Validation**: YAML syntax and dependency checking
2. **Generation**: Terraform module creation
3. **Planning**: Terraform plan generation
4. **Deployment**: Infrastructure provisioning via Terraform

### 4. Environment Management

- Separate state files for development and production
- Environment-specific configurations
- Approval workflows for production deployments

## Required AWS IAM Permissions

### 1. Validation Role (`AWS_VALIDATION_ROLE`)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:GetAgent",
        "bedrock:ListAgents",
        "lambda:GetFunction",
        "lambda:ListFunctions",
        "iam:GetRole",
        "iam:ListRoles"
      ],
      "Resource": "*"
    }
  ]
}
```

### 2. Deployment Role (`AWS_DEPLOYMENT_ROLE`)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:*",
        "lambda:*",
        "iam:*",
        "s3:GetObject",
        "s3:PutObject",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

## GitHub Repository Configuration

### Required Secrets

Configure these secrets in your GitHub repository settings (`Settings > Secrets and variables > Actions`):

1. **`AWS_VALIDATION_ROLE`**: ARN of the IAM role for validation
   - Example: `arn:aws:iam::123456789012:role/BedrockForgeValidationRole`

2. **`AWS_DEPLOYMENT_ROLE`**: ARN of the IAM role for deployment
   - Example: `arn:aws:iam::123456789012:role/BedrockForgeDeploymentRole`

3. **`TERRAFORM_STATE_BUCKET`**: S3 bucket for Terraform state storage
   - Example: `my-terraform-state-bucket`

4. **`TERRAFORM_ARTIFACTS_BUCKET`**: S3 bucket for build artifacts
   - Example: `my-terraform-artifacts-bucket`

### Environment Configuration

Create GitHub environments for deployment approval:

1. **Development Environment**:
   - No approval required
   - Automatic deployment on main branch push

2. **Production Environment**:
   - Required reviewers configured
   - Manual approval required

## Usage Instructions

### 1. Initial Setup

1. Fork or clone this repository
2. Configure the required GitHub secrets
3. Set up AWS IAM roles with appropriate permissions
4. Create S3 buckets for state and artifacts storage

### 2. Making Changes

1. Create a feature branch
2. Modify YAML configurations as needed
3. Create a pull request
4. Review the validation results and generated Terraform
5. Merge to main branch for deployment

### 3. Deployment Process

1. **Automatic Validation**: On PR creation, validation workflow runs
2. **Development Deployment**: On merge to main, deploys to dev environment
3. **Production Deployment**: Requires manual approval, then deploys to prod

### 4. Monitoring

- Check GitHub Actions for deployment status
- Monitor AWS CloudWatch logs for Lambda function execution
- Use AWS Bedrock console to test agent functionality

## Project Structure

```
customer-agent/
├── .github/
│   └── workflows/
│       ├── validate-bedrock.yml
│       └── deploy-bedrock.yml
├── lambda-functions/
│   └── hr-lambda/
│       └── lambda_function.py
├── hr-agent.yml
├── hr-lambda.yml
├── README.md
└── outputs_tf/ (generated by bedrock-forge)
```

## Testing the Agent

Once deployed, you can test the HR assistant agent by:

1. Using the AWS Bedrock console to invoke the agent
2. Asking questions like:
   - "How many vacation days do I have available?"
   - "I want to book vacation from 2024-07-15 to 2024-07-20"
   - "What's the company vacation policy?"

## Benefits of Using Bedrock-Forge

1. **Simplified Configuration**: YAML-based declarative approach
2. **Automatic IAM Management**: No manual IAM policy creation
3. **Dependency Resolution**: Automatic handling of resource dependencies
4. **CI/CD Integration**: Built-in GitHub Actions workflows
5. **Environment Management**: Support for multiple deployment environments
6. **Validation**: Early detection of configuration errors
7. **Terraform Integration**: Leverages Terraform for infrastructure management

## Troubleshooting

### Common Issues

1. **IAM Permission Errors**: Ensure deployment role has sufficient permissions
2. **Terraform State Conflicts**: Use separate state files for different environments
3. **Lambda Function Errors**: Check CloudWatch logs for debugging
4. **Agent Invocation Failures**: Verify IAM roles and resource policies

### Support

For issues related to bedrock-forge, refer to:
- [Bedrock-Forge Documentation](https://github.com/chandra447/bedrock-forge)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Create a pull request
5. Await review and approval

## Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Query    │───▶│  Bedrock Agent  │───▶│ Lambda Function │
│                 │    │   (Mistral 7B)  │    │  (HR Logic)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                │                        ▼
                                │                ┌─────────────────┐
                                │                │  SQLite DB      │
                                │                │ (Employee Data) │
                                │                └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Response to   │
                       │      User       │
                       └─────────────────┘
```

This implementation provides a complete, production-ready HR assistant agent using the bedrock-forge framework for simplified AWS Bedrock deployment.
