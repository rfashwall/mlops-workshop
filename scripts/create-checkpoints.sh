#!/bin/bash

# Create checkpoint branches for each workshop module
set -e

echo "🌿 Creating checkpoint branches for MLOps Workshop..."

# Ensure we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Please run 'git init' first."
    exit 1
fi

# Create checkpoint branches
CHECKPOINTS=(
    "checkpoint-start"
    "checkpoint-module1-complete"
    "checkpoint-module2-complete"
    "checkpoint-module3-complete"
    "checkpoint-module4-complete"
    "checkpoint-module5-complete"
    "checkpoint-module6-complete"
    "checkpoint-workshop-complete"
)

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

for checkpoint in "${CHECKPOINTS[@]}"; do
    if git show-ref --verify --quiet refs/heads/$checkpoint; then
        echo "✅ Branch $checkpoint already exists"
    else
        echo "🌿 Creating branch $checkpoint"
        git checkout -b $checkpoint
        git checkout $CURRENT_BRANCH
    fi
done

echo "✅ All checkpoint branches created successfully!"
echo ""
echo "📋 Available checkpoints:"
for checkpoint in "${CHECKPOINTS[@]}"; do
    echo "  - $checkpoint"
done
echo ""
echo "💡 Use 'bash scripts/switch-checkpoint.sh <checkpoint-name>' to switch between checkpoints"