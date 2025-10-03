#!/usr/bin/env bash
# This script extracts the .NET project version from a .csproj file.

set -e

usage() {
    echo "Usage:" >&2
    echo "  $0 <FILE>" >&2
}

# Ensure README file exists.
if [ $# -lt 1 ] || [ ! -f $1 ]; then
    echo "File '$1' not found!" >&2
    usage
    exit 1
fi

# Splits lines into fields, with `<` and `>` as the separators.
awk -F'[><]' '/<Version>/{print $3}' $1