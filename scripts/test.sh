#!/bin/bash
set -e

echo "=== Running tests ==="
echo "Workspace: $(pwd)"

if [ ! -d "scripts" ]; then echo "FAIL: reason"; exit 1; fi

echo "=== All tests passed ==="
