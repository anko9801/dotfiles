#!/usr/bin/env bash
# Legacy installer - now redirects to bundle

# Simply call bundle with all arguments
exec "$(dirname "$0")/bundle" "$@"