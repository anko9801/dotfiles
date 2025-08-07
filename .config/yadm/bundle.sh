#!/usr/bin/env bash
# Bundle wrapper - installs deno if needed and runs bundle

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install deno if not available
if ! command -v deno &>/dev/null; then
    echo "Installing Deno..."
    
    # Try to install via mise if available
    if command -v mise &>/dev/null; then
        mise install deno@latest >/dev/null 2>&1 && eval "$(mise activate bash 2>/dev/null)" || true
    fi
    
    # If still not available, install directly
    if ! command -v deno &>/dev/null; then
        export DENO_INSTALL="${DENO_INSTALL:-$HOME/.deno}"
        curl -fsSL https://deno.land/install.sh | sh >/dev/null 2>&1 || {
            echo "Error: Failed to install Deno" >&2
            exit 1
        }
        export PATH="$DENO_INSTALL/bin:$PATH"
    fi
fi

# Run bundle with deno
exec deno run -A "$SCRIPT_DIR/bundle/bundle.ts" "$@"