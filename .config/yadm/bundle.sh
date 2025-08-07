#!/usr/bin/env bash
# Bundle wrapper - fast and idempotent

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v deno &>/dev/null; then
    exec deno run -A "$SCRIPT_DIR/bundle/bundle.ts" "$@"
else
    echo "Error: Deno is required. Install via: curl -fsSL https://deno.land/install.sh | sh" >&2
    exit 1
fi