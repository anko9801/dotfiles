#!/bin/bash
set -u

export TERM="xterm-256color"
# Completely disable mise in CI (avoids SSH auth failures for pyenv/rbenv)
export __MISE_DISABLED=1

echo "==> Benchmarking zsh first prompt..."

# zsh time-to-first-prompt (10 iterations)
# Measures how quickly the prompt appears (deferred items load after prompt)
total_zsh=0
for i in $(seq 1 10); do
  start=$(date +%s%N)
  zsh -i -c exit 2>/dev/null || true
  end=$(date +%s%N)
  elapsed=$(((end - start) / 1000000))
  total_zsh=$((total_zsh + elapsed))
done
zsh_startup=$((total_zsh / 10))
echo "zsh first prompt: ${zsh_startup}ms"

# zsh full init (10 iterations)
# Measures total time including deferred items (compinit, fzf, direnv, atuin, plugins)
echo "==> Benchmarking zsh full init..."
total_zsh_full=0
for i in $(seq 1 10); do
  start=$(date +%s%N)
  zsh -i -c '
    (( $+functions[_init_deferred] )) && _init_deferred
    (( $+functions[_init_shell_options] )) && _init_shell_options
  ' 2>/dev/null || true
  end=$(date +%s%N)
  elapsed=$(((end - start) / 1000000))
  total_zsh_full=$((total_zsh_full + elapsed))
done
zsh_full=$((total_zsh_full / 10))
echo "zsh full init: ${zsh_full}ms"

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
        "name": "zsh first prompt",
        "unit": "ms",
        "value": ${zsh_startup}
    },
    {
        "name": "zsh full init",
        "unit": "ms",
        "value": ${zsh_full}
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
