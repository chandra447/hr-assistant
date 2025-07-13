#!/bin/bash

# Configuration
PROJECT_NAME="hr-assistant-bedrock"
GITHUB_REPO="chandra447/hr-assistant"  # Your actual repo
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Role names
VALIDATION_ROLE_NAME="${PROJECT_NAME}-validation-role"
DEPLOYMENT_ROLE_NAME="${PROJECT_NAME}-deployment-role"

echo "Creating IAM roles for GitHub Actions..."
echo "Account ID: ${ACCOUNT_ID}"
echo "GitHub Repo: ${GITHUB_REPO}"

# Create trust policy for GitHub Actions OIDC
cat > github-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF

# Create validation role policy
cat > validation-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:GetAgent",
        "bedrock:ListAgents",
        "bedrock:GetFoundationModel",
        "bedrock:ListFoundationModels",
        "lambda:GetFunction",
        "lambda:ListFunctions",
        "iam:GetRole",
        "iam:ListRoles",
        "iam:GetPolicy",
        "iam:ListPolicies",
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create deployment role policy
cat > deployment-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:*",
        "lambda:*",
        "iam:*",
        "s3:*",
        "logs:*",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:AttachNetworkInterface",
        "ec2:DetachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Check if OIDC provider exists
if ! aws iam get-open-id-connect-provider --open-id-connect-provider-arn "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com" >/dev/null 2>&1; then
    echo "Creating GitHub OIDC provider..."
    aws iam create-open-id-connect-provider \
        --url https://token.actions.githubusercontent.com \
        --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
        --client-id-list sts.amazonaws.com
else
    echo "GitHub OIDC provider already exists"
fi

# Create validation role
echo "Creating validation role: ${VALIDATION_ROLE_NAME}"
aws iam create-role \
    --role-name "${VALIDATION_ROLE_NAME}" \
    --assume-role-policy-document file://github-trust-policy.json \
    --description "Role for validating Bedrock configurations in GitHub Actions"

# Attach policy to validation role
aws iam put-role-policy \
    --role-name "${VALIDATION_ROLE_NAME}" \
    --policy-name "ValidationPolicy" \
    --policy-document file://validation-policy.json

# Create deployment role
echo "Creating deployment role: ${DEPLOYMENT_ROLE_NAME}"
aws iam create-role \
    --role-name "${DEPLOYMENT_ROLE_NAME}" \
    --assume-role-policy-document file://github-trust-policy.json \
    --description "Role for deploying Bedrock resources in GitHub Actions"

# Attach policy to deployment role
aws iam put-role-policy \
    --role-name "${DEPLOYMENT_ROLE_NAME}" \
    --policy-name "DeploymentPolicy" \
    --policy-document file://deployment-policy.json

# Clean up temporary files
rm -f github-trust-policy.json validation-policy.json deployment-policy.json

echo "IAM roles created successfully!"
echo ""
echo "Add these to your GitHub secrets:"
echo "AWS_VALIDATION_ROLE=arn:aws:iam::${ACCOUNT_ID}:role/${VALIDATION_ROLE_NAME}"
echo "AWS_DEPLOYMENT_ROLE=arn:aws:iam::${ACCOUNT_ID}:role/${DEPLOYMENT_ROLE_NAME}"
echo ""
echo "Don't forget to update the GITHUB_REPO variable in this script with your actual repository!"
