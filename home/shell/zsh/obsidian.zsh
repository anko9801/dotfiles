# Obsidian functions (CANNOT DEFER: nested function definitions become local and are lost when outer function exits)

# Convert date format from Obsidian style to date command style
# YYYY-MM-DD HH:mm:ss → %Y-%m-%d %H:%M:%S
_convert-date-format() {
  local input_format="$1"
  [[ -z "$input_format" ]] && read -r input_format
  local output_format="$input_format"
  output_format="${output_format//YYYY/%Y}"
  output_format="${output_format//MM/%m}"
  output_format="${output_format//DD/%d}"
  output_format="${output_format//HH/%H}"
  output_format="${output_format//mm/%M}"
  output_format="${output_format//ss/%S}"
  echo "$output_format"
}

# Create or append to Obsidian daily note
obsidian-daily-note() {
  local vault_path=$OBSIDIAN_VAULT_PATH
  if [[ -z "$vault_path" ]]; then
    echo "Error: OBSIDIAN_VAULT_PATH is not set." >&2
    return 1
  fi

  local dn_config_path="${vault_path}/.obsidian/daily-notes.json"
  if [[ ! -f "$dn_config_path" ]]; then
    echo "Error: daily-notes.json not found" >&2
    return 1
  fi

  local dn_folder=$(jq -r '.folder' "$dn_config_path")
  local dn_path_format=$(jq -r '.format' "$dn_config_path" | _convert-date-format)
  local dn_path="${vault_path}/${dn_folder}/$(date +"${dn_path_format}").md"

  [[ ! -f "$dn_path" ]] && mkdir -p "$(dirname "$dn_path")"

  local dn_header="$(date '+%Y-%m-%d %H:%M:%S')"
  cat >> "$dn_path" << EOF

### $dn_header


EOF

  local dn_message="$1"
  if [[ -n "$dn_message" ]]; then
    echo -e "$dn_message\n" >> "$dn_path"
  else
    $EDITOR + "$dn_path"
  fi
}

# Create Obsidian unique note (Zettelkasten style)
obsidian-unique-note() {
  local vault_path=$OBSIDIAN_VAULT_PATH
  if [[ -z "$vault_path" ]]; then
    echo "Error: OBSIDIAN_VAULT_PATH is not set." >&2
    return 1
  fi

  local note_title="$1"
  if [[ -z "$note_title" ]]; then
    echo "Usage: obsidian-unique-note <note-title>" >&2
    return 1
  fi

  local un_config_path="${vault_path}/.obsidian/zk-prefixer.json"
  local un_folder un_prefix_format un_prefix un_path

  if [[ -f "$un_config_path" ]]; then
    un_folder=$(jq -r '.folder' "$un_config_path")
    un_prefix_format=$(jq -r '.format' "$un_config_path" | _convert-date-format)
  else
    un_folder="Zettelkasten"
    un_prefix_format="%Y%m%d%H%M%S"
  fi

  un_prefix=$(date +"${un_prefix_format}")
  un_path="${vault_path}/${un_folder}/${un_prefix}_${note_title}.md"

  mkdir -p "$(dirname "$un_path")"
  cat > "$un_path" << EOF
---
title: $note_title
created_at: $(date '+%Y-%m-%dT%H:%M:%S')
updated_at: $(date '+%Y-%m-%dT%H:%M:%S')
---

EOF

  $EDITOR + "$un_path"
}

# Aliases (odn/oun to avoid conflict with system 'od' command)
alias odn='obsidian-daily-note'
alias oun='obsidian-unique-note'
