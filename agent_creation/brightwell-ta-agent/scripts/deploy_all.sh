#!/bin/bash
set -e

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "=========================================="
echo "Deploying Brightwell TA Screening Assistant"
echo "=========================================="

cd "$PROJECT_ROOT"

echo "Step 1: Importing tools..."
"$SCRIPT_DIR/import_tools.sh"

echo ""
echo "Step 2: Importing knowledge base..."
"$SCRIPT_DIR/import_kb.sh"

echo ""
echo "Step 3: Deploying agent..."
"$SCRIPT_DIR/deploy_agent.sh"

echo ""
echo "=========================================="
echo "✓ Brightwell TA Screening Assistant deployed successfully!"
echo "=========================================="

# Made with Bob
