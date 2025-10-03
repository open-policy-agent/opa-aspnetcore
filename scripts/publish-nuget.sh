#!/bin/bash

# Usage: ./publish-nuget.sh <nuget_directory> <api_key>

NUGET_DIR="$1"
API_KEY="$2"

if [ -z "$NUGET_DIR" ] || [ -z "$API_KEY" ]; then
    echo "Usage: $0 <nuget_directory> <api_key>"
    exit 1
fi

for file in "$NUGET_DIR"/*.nupkg; do
    if [ -f "$file" ]; then
        dotnet nuget push "$file" --api-key "$API_KEY" --source https://api.nuget.org/v3/index.json --skip-duplicate
    fi
done