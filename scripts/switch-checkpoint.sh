#!/bin/bash

# Switch to a specific checkpoint branch
set -e

if [ $# -eq 0 ]; then
    echo "❌ Please provide a checkpoint name"
    echo ""
    echo "📋 Available checkpoints:"
    git branch | grep checkpoint | sed 's/^../  - /'
    echo ""
    echo "Usage: bash scripts/switch-checkpoint.sh <checkpoint-name>"
    exit 1
fi

CHECKPOINT=$1

# Check if checkpoint exists
if ! git show-ref --verify --quiet refs/heads/$CHECKPOINT; then
    echo "❌ Checkpoint '$CHECKPOINT' does not exist"
    echo ""
    echo "📋 Available checkpoints:"
    git branch | grep checkpoint | sed 's/^../  - /'
    exit 1
fi

# Save current work if there are uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "💾 Saving current work..."
    CURRENT_BRANCH=$(git branch --show-current)
    git add .
    git commit -m "WIP: Saving work before switching to $CHECKPOINT" || true
fi

# Switch to checkpoint
echo "🔄 Switching to checkpoint: $CHECKPOINT"
git checkout $CHECKPOINT

echo "✅ Successfully switched to $CHECKPOINT"
echo ""
echo "📖 You are now at checkpoint: $CHECKPOINT"
echo "💡 Use 'git log --oneline' to see the commit history"