#!/bin/bash
#
# Simple shell script to check if running in cloud/CI environment
# This can run without Flutter/Dart being installed
#
# Usage:
#   ./scripts/check_cloud_environment.sh
#
# Note: Ensure the script has execute permissions:
#   chmod +x scripts/check_cloud_environment.sh

echo "=== Cloud/CI Environment Detection ==="
echo ""
echo "Checking environment variables..."
echo ""

# Check for CI environment
if [ "$CI" = "true" ]; then
    echo "✅ CI=true - Running in CI environment"
else
    echo "❌ CI is not set or not true"
fi

# Check for GitHub Actions
if [ "$GITHUB_ACTIONS" = "true" ]; then
    echo "✅ GITHUB_ACTIONS=true - Running in GitHub Actions"
    echo "   Workflow: $GITHUB_WORKFLOW"
    echo "   Runner: $RUNNER_NAME"
    echo "   OS: $RUNNER_OS"
    echo "   Environment: $RUNNER_ENVIRONMENT"
else
    echo "❌ GITHUB_ACTIONS is not set or not true"
fi

# Check for Azure Pipelines
if [ "$TF_BUILD" = "True" ]; then
    echo "✅ TF_BUILD=True - Running in Azure Pipelines"
else
    echo "❌ TF_BUILD is not set"
fi

echo ""
echo "=== ANSWER ==="
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ] || [ "$TF_BUILD" = "True" ]; then
    echo "✅ YES - This task IS running in the cloud"
    if [ "$GITHUB_ACTIONS" = "true" ]; then
        echo "   Platform: GitHub Actions"
    elif [ "$TF_BUILD" = "True" ]; then
        echo "   Platform: Azure Pipelines"
    else
        echo "   Platform: CI (Unknown)"
    fi
else
    echo "❌ NO - This task is running locally"
fi

echo ""
echo "=== Environment Details ==="
env | grep -E "(CI|GITHUB_|RUNNER_|TF_BUILD)" | sort
