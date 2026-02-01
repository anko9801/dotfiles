#!/bin/bash
set -eu

export TERM="xterm-256color"
# Disable mise network access in CI (avoids SSH auth failures)
export MISE_OFFLINE=1
export MISE_NO_AUTO_INSTALL=1
export MISE_YES=1

echo "==> Benchmarking zsh startup..."

# zsh startup (10 iterations)
total_zsh=0
for i in $(seq 1 10); do
  start=$(date +%s%N)
  zsh -i -c exit
  end=$(date +%s%N)
  elapsed=$(((end - start) / 1000000))
  total_zsh=$((total_zsh + elapsed))
done
zsh_startup=$((total_zsh / 10))
echo "zsh average: ${zsh_startup}ms"

# neovim startup (10 iterations)
echo "==> Benchmarking neovim startup..."
nvim_startup=0
if command -v nvim >/dev/null 2>&1; then
  total_nvim=0
  for i in $(seq 1 10); do
    start=$(date +%s%N)
    nvim --headless -c 'quit' 2>/dev/null
    end=$(date +%s%N)
    elapsed=$(((end - start) / 1000000))
    total_nvim=$((total_nvim + elapsed))
  done
  nvim_startup=$((total_nvim / 10))
  echo "nvim average: ${nvim_startup}ms"
else
  echo "neovim not found, skipping"
  nvim_startup=0
fi

# Output JSON result
cat <<EOJ | tee /tmp/result-benchmark.json
[
    {
        "name": "zsh startup",
        "unit": "ms",
        "value": ${zsh_startup}
    },
    {
        "name": "neovim startup",
        "unit": "ms",
        "value": ${nvim_startup}
    }
]
EOJ

echo "==> Benchmark complete!"
