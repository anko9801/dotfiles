#!/bin/bash
set -u

export TERM="xterm-256color"
# Completely disable mise in CI (avoids SSH auth failures for pyenv/rbenv)
export __MISE_DISABLED=1

echo "==> Benchmarking zsh startup..."

# zsh startup (10 iterations)
# Note: zsh -i may return non-zero due to warnings in CI, so we ignore the exit code
total_zsh=0
for i in $(seq 1 10); do
  start=$(date +%s%N)
  zsh -i -c exit 2>/dev/null || true
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
    nvim --headless -c 'quit' 2>/dev/null || true
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

# starship prompt render (10 iterations)
echo "==> Benchmarking starship prompt..."
starship_time=0
if command -v starship >/dev/null 2>&1; then
  total_starship=0
  for i in $(seq 1 10); do
    start=$(date +%s%N)
    starship prompt >/dev/null 2>&1 || true
    end=$(date +%s%N)
    elapsed=$(((end - start) / 1000000))
    total_starship=$((total_starship + elapsed))
  done
  starship_time=$((total_starship / 10))
  echo "starship average: ${starship_time}ms"
else
  echo "starship not found, skipping"
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
    },
    {
        "name": "starship prompt",
        "unit": "ms",
        "value": ${starship_time}
    }
]
EOJ

echo "==> Benchmark complete!"
