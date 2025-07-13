#!/bin/bash

# Configuration
AWS_REGION="ap-southeast-2"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
PROJECT_NAME="hr-assistant-bedrock"

# Bucket names (must be globally unique)
TERRAFORM_STATE_BUCKET="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}"
TERRAFORM_ARTIFACTS_BUCKET="${PROJECT_NAME}-terraform-artifacts-${ACCOUNT_ID}"

echo "Creating S3 buckets for Terraform state and artifacts..."
echo "Account ID: ${ACCOUNT_ID}"
echo "Region: ${AWS_REGION}"

# Create Terraform state bucket
echo "Creating Terraform state bucket: ${TERRAFORM_STATE_BUCKET}"
aws s3api create-bucket \
    --bucket "${TERRAFORM_STATE_BUCKET}" \
    --region "${AWS_REGION}" \
    --create-bucket-configuration LocationConstraint="${AWS_REGION}"

# Enable versioning for state bucket
aws s3api put-bucket-versioning \
    --bucket "${TERRAFORM_STATE_BUCKET}" \
    --versioning-configuration Status=Enabled

# Enable server-side encryption for state bucket
aws s3api put-bucket-encryption \
    --bucket "${TERRAFORM_STATE_BUCKET}" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access for state bucket
aws s3api put-public-access-block \
    --bucket "${TERRAFORM_STATE_BUCKET}" \
    --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create Terraform artifacts bucket
echo "Creating Terraform artifacts bucket: ${TERRAFORM_ARTIFACTS_BUCKET}"
aws s3api create-bucket \
    --bucket "${TERRAFORM_ARTIFACTS_BUCKET}" \
    --region "${AWS_REGION}" \
    --create-bucket-configuration LocationConstraint="${AWS_REGION}"

# Enable versioning for artifacts bucket
aws s3api put-bucket-versioning \
    --bucket "${TERRAFORM_ARTIFACTS_BUCKET}" \
    --versioning-configuration Status=Enabled

# Enable server-side encryption for artifacts bucket
aws s3api put-bucket-encryption \
    --bucket "${TERRAFORM_ARTIFACTS_BUCKET}" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access for artifacts bucket
aws s3api put-public-access-block \
    --bucket "${TERRAFORM_ARTIFACTS_BUCKET}" \
    --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "S3 buckets created successfully!"
echo "Terraform State Bucket: ${TERRAFORM_STATE_BUCKET}"
echo "Terraform Artifacts Bucket: ${TERRAFORM_ARTIFACTS_BUCKET}"
echo ""
echo "Add these to your GitHub secrets:"
echo "TERRAFORM_STATE_BUCKET=${TERRAFORM_STATE_BUCKET}"
echo "TERRAFORM_ARTIFACTS_BUCKET=${TERRAFORM_ARTIFACTS_BUCKET}"
