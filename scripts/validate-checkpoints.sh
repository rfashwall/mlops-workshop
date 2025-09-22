#!/bin/bash

# Validate that all checkpoint branches exist and are properly configured
set -e

echo "🔍 Validating checkpoint branches..."

EXPECTED_CHECKPOINTS=(
    "checkpoint-start"
    "checkpoint-module1-complete"
    "checkpoint-module2-complete"
    "checkpoint-module3-complete"
    "checkpoint-module4-complete"
    "checkpoint-module5-complete"
    "checkpoint-module6-complete"
    "checkpoint-workshop-complete"
)

MISSING_CHECKPOINTS=()
EXISTING_CHECKPOINTS=()

for checkpoint in "${EXPECTED_CHECKPOINTS[@]}"; do
    if git show-ref --verify --quiet refs/heads/$checkpoint; then
        EXISTING_CHECKPOINTS+=($checkpoint)
        echo "✅ $checkpoint exists"
    else
        MISSING_CHECKPOINTS+=($checkpoint)
        echo "❌ $checkpoint missing"
    fi
done

echo ""
echo "📊 Checkpoint Summary:"
echo "  ✅ Existing: ${#EXISTING_CHECKPOINTS[@]}"
echo "  ❌ Missing: ${#MISSING_CHECKPOINTS[@]}"

if [ ${#MISSING_CHECKPOINTS[@]} -gt 0 ]; then
    echo ""
    echo "🔧 Missing checkpoints:"
    for checkpoint in "${MISSING_CHECKPOINTS[@]}"; do
        echo "  - $checkpoint"
    done
    echo ""
    echo "💡 Run 'bash scripts/create-checkpoints.sh' to create missing checkpoints"
    exit 1
else
    echo ""
    echo "🎉 All checkpoint branches are properly configured!"
fi