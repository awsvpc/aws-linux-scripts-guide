#!/bin/bash

# Get a list of all AWS regions
REGIONS=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)

# Loop through each region
for region in $REGIONS; do
    echo "Checking region: $region"

    # Get a list of all CloudFormation stacks in the region
    STACKS=$(aws cloudformation list-stacks --region "$region" --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[*].StackName" --output text)

    # Check if there are any stacks in this region
    if [ -n "$STACKS" ]; then
        # Loop through each stack
        for stack in $STACKS; do
            # Describe the stack resources
            RESOURCES=$(aws cloudformation describe-stack-resources --region "$region" --stack-name "$stack" --query "StackResources[?ResourceType=='AWS::IAM::Role'].PhysicalResourceId" --output text)

            # Check if there are any IAM roles in this stack
            if [ -n "$RESOURCES" ]; then
                # Loop through each IAM role
                for role in $RESOURCES; do
                    echo "'$region', '$stack', '$role'"
                done
            fi
        done
    else
        echo "No stacks found in region: $region"
    fi
done
