#!/bin/bash
set -e

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Importing tools..."
cd "$PROJECT_ROOT"

echo "1. Importing requisition_tools.py..."
uvx --from ibm-watsonx-orchestrate orchestrate tools import -k python -f tools/requisition_tools.py
echo "✓ Requisition tools imported"

echo "2. Importing candidate_tools.py..."
uvx --from ibm-watsonx-orchestrate orchestrate tools import -k python -f tools/candidate_tools.py
echo "✓ Candidate tools imported"

echo "3. Importing screening_tools.py..."
uvx --from ibm-watsonx-orchestrate orchestrate tools import -k python -f tools/screening_tools.py
echo "✓ Screening tools imported"

echo "=========================================="
echo "✓ All tools imported successfully!"
echo "=========================================="

# Made with Bob
