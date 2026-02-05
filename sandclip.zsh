# ── helpers ──────────────────────────────────────────────────────────────────

# Interactive menu with vim key support. Prints the chosen line to stdout.
# Usage: _sandclip_menu "header" "option1" "option2" ...
_sandclip_menu() {
  local header="$1"; shift
  local -a items=("$@")
  local cur=0 total=${#items[@]} key

  # hide cursor
  tput civis 2>/dev/null >&2

  local _cleanup() { tput cnorm 2>/dev/null >&2; }
  trap '_cleanup; return 1' INT
  trap '_cleanup' EXIT

  while true; do
    # draw
    printf '\r\033[K%s\n' "$header" >&2
    for i in {0..$((total - 1))}; do
      if (( i == cur )); then
        printf '\033[K  \033[1;36m❯ %s\033[0m\n' "${items[$((i+1))]}" >&2
      else
        printf '\033[K    %s\n' "${items[$((i+1))]}" >&2
      fi
    done

    # read a keypress; if EOF (Ctrl+D) read returns non-zero
    if ! read -rsk1 key; then
      _cleanup
      return 1
    fi
    case "$key" in
      $'\x03') _cleanup; return 1 ;;  # Ctrl+C (raw)
      $'\x04') _cleanup; return 1 ;;  # Ctrl+D (raw)
      j|$'\x1b')  # j or start of arrow sequence
        if [[ "$key" == $'\x1b' ]]; then
          read -rsk1 -t 0.01 key
          if [[ "$key" == "[" ]]; then
            read -rsk1 -t 0.01 key
            [[ "$key" == "B" ]] && (( cur = (cur + 1) % total ))
            [[ "$key" == "A" ]] && (( cur = (cur - 1 + total) % total ))
          fi
        else
          (( cur = (cur + 1) % total ))
        fi
        ;;
      k) (( cur = (cur - 1 + total) % total )) ;;
      $'\n') break ;;  # enter
      q) _cleanup; return 1 ;;
    esac

    # move cursor back up to redraw
    printf '\033[%dA' "$((total + 1))" >&2
  done

  _cleanup
  echo "${items[$((cur+1))]}"
}

# Generate a unique VM name based on cwd: sandbox-<dirname>[-N]
_sandclip_default_name() {
  local base="sandbox-${PWD:t}"
  # sanitize: lowercase, replace non-alphanumeric with dash
  base="${base:l}"
  base="${base//[^a-z0-9-]/-}"

  local existing
  existing=$(limactl list -q 2>/dev/null)

  if ! echo "$existing" | grep -qx "$base"; then
    echo "$base"
    return
  fi

  local n=2
  while echo "$existing" | grep -qx "${base}-${n}"; do
    (( n++ ))
  done
  echo "${base}-${n}"
}

# Resolve the latest release download URL for the qcow2 image.
# Uses the tag-specific URL so Lima caches each release separately.
_sandclip_image_url() {
  local arch_suffix="$1"
  local tag

  # Try gh CLI first (fastest, already authenticated)
  if command -v gh &>/dev/null; then
    tag=$(gh api repos/idpbond/config/releases/latest --jq '.tag_name' 2>/dev/null)
  fi

  # Fall back to curl if gh unavailable or failed
  if [[ -z "$tag" ]]; then
    tag=$(curl -fsSL -o /dev/null -w '%{redirect_url}' \
      https://github.com/idpbond/config/releases/latest 2>/dev/null \
      | grep -o '[^/]*$')
  fi

  if [[ -n "$tag" ]]; then
    echo "https://github.com/idpbond/config/releases/download/${tag}/sandclip-${arch_suffix}.qcow2.gz"
  else
    # Last resort: use the /latest/ redirect URL (Lima cache won't distinguish releases)
    echo "https://github.com/idpbond/config/releases/latest/download/sandclip-${arch_suffix}.qcow2.gz"
  fi
}

# Interactive config screen for VM creation.
# Prints "cpus|mem|network_mode" to stdout, or returns 1 on cancel.
_sandclip_config() {
  local name="$1"

  local max_cpus=$(sysctl -n hw.ncpu)
  local total_mem_bytes=$(sysctl -n hw.memsize)
  local total_gib=$(( total_mem_bytes / 1073741824 ))

  local cpus=$(( max_cpus / 2 ))
  (( cpus < 1 )) && cpus=1
  local mem=$(( total_gib / 2 ))
  (( mem < 1 )) && mem=1

  local -a net_modes=("Default" "Bridged (own LAN IP)")
  local net_idx=0

  local cur_field=0
  local num_fields=3
  local key

  tput civis 2>/dev/null >&2

  local _cleanup() { tput cnorm 2>/dev/null >&2; }
  trap '_cleanup; return 1' INT
  trap '_cleanup' EXIT

  local first=true
  while true; do
    # move cursor up to redraw (skip on first draw)
    if [[ "$first" == true ]]; then
      first=false
    else
      printf '\033[8A' >&2
    fi

    # draw
    printf '\033[K\n' >&2
    printf '\033[K  Create sandbox: \033[1m%s\033[0m\n' "$name" >&2
    printf '\033[K\n' >&2

    # CPUs field
    if (( cur_field == 0 )); then
      printf '\033[K  \033[1;36m❯ CPUs       ◀ %d ▶\033[0m\n' "$cpus" >&2
    else
      printf '\033[K    CPUs       ◀ %d ▶\n' "$cpus" >&2
    fi

    # Memory field
    if (( cur_field == 1 )); then
      printf '\033[K  \033[1;36m❯ Memory     ◀ %d GiB ▶\033[0m\n' "$mem" >&2
    else
      printf '\033[K    Memory     ◀ %d GiB ▶\n' "$mem" >&2
    fi

    # Network field
    if (( cur_field == 2 )); then
      printf '\033[K  \033[1;36m❯ Network    ◀ %s ▶\033[0m\n' "${net_modes[$((net_idx+1))]}" >&2
    else
      printf '\033[K    Network    ◀ %s ▶\n' "${net_modes[$((net_idx+1))]}" >&2
    fi

    printf '\033[K\n' >&2
    printf '\033[K  h/l to adjust, j/k to move, enter to create, q to cancel\n' >&2

    if ! read -rsk1 key; then
      _cleanup
      return 1
    fi

    case "$key" in
      $'\x03'|$'\x04') _cleanup; return 1 ;;
      q) _cleanup; return 1 ;;
      j) (( cur_field = (cur_field + 1) % num_fields )) ;;
      k) (( cur_field = (cur_field - 1 + num_fields) % num_fields )) ;;
      $'\x1b')
        read -rsk1 -t 0.01 key
        if [[ "$key" == "[" ]]; then
          read -rsk1 -t 0.01 key
          case "$key" in
            B) (( cur_field = (cur_field + 1) % num_fields )) ;;
            A) (( cur_field = (cur_field - 1 + num_fields) % num_fields )) ;;
            D)  # left arrow = h
              case $cur_field in
                0) (( cpus > 1 )) && (( cpus-- )) ;;
                1) (( mem > 1 )) && (( mem-- )) ;;
                2) (( net_idx = 1 - net_idx )) ;;
              esac
              ;;
            C)  # right arrow = l
              case $cur_field in
                0) (( cpus < max_cpus )) && (( cpus++ )) ;;
                1) (( mem < total_gib )) && (( mem++ )) ;;
                2) (( net_idx = 1 - net_idx )) ;;
              esac
              ;;
          esac
        fi
        ;;
      h)
        case $cur_field in
          0) (( cpus > 1 )) && (( cpus-- )) ;;
          1) (( mem > 1 )) && (( mem-- )) ;;
          2) (( net_idx = 1 - net_idx )) ;;
        esac
        ;;
      l)
        case $cur_field in
          0) (( cpus < max_cpus )) && (( cpus++ )) ;;
          1) (( mem < total_gib )) && (( mem++ )) ;;
          2) (( net_idx = 1 - net_idx )) ;;
        esac
        ;;
      $'\n')
        break
        ;;
    esac
  done

  _cleanup

  local net_mode="default"
  (( net_idx == 1 )) && net_mode="bridged"
  echo "${cpus}|${mem}|${net_mode}"
}

# Create and start a new sandbox VM
# Usage: _sandclip_create <name> <cpus> <mem_gib> <network_mode>
_sandclip_create() {
  local name="$1"
  local cpus="$2"
  local mem_gib="$3"
  local network_mode="$4"

  local arch arch_suffix
  case "$(uname -m)" in
    arm64) arch="aarch64"; arch_suffix="arm64" ;;
    *)     arch="x86_64";  arch_suffix="amd64" ;;
  esac

  local image_url
  image_url=$(_sandclip_image_url "$arch_suffix")

  # Detect and set up socket_vmnet for bridged networking (only when bridged selected)
  local has_vmnet=false
  if [[ "$network_mode" == "bridged" ]]; then
    if [[ -e /opt/socket_vmnet/bin/socket_vmnet ]]; then
      has_vmnet=true
    elif [[ -e /opt/homebrew/opt/socket_vmnet/bin/socket_vmnet ]] || \
         [[ -e /usr/local/opt/socket_vmnet/bin/socket_vmnet ]]; then
      local brew_bin=""
      [[ -e /opt/homebrew/opt/socket_vmnet/bin/socket_vmnet ]] && brew_bin="/opt/homebrew/Cellar/socket_vmnet/$(ls /opt/homebrew/Cellar/socket_vmnet/ 2>/dev/null | head -1)/bin/socket_vmnet"
      [[ -z "$brew_bin" && -e /usr/local/opt/socket_vmnet/bin/socket_vmnet ]] && brew_bin="/usr/local/Cellar/socket_vmnet/$(ls /usr/local/Cellar/socket_vmnet/ 2>/dev/null | head -1)/bin/socket_vmnet"
      if [[ -n "$brew_bin" && -e "$brew_bin" ]]; then
        echo "socket_vmnet found via Homebrew but not at /opt/socket_vmnet/bin/"
        echo "Copying to Lima's expected path (requires sudo)..."
        sudo mkdir -p /opt/socket_vmnet/bin && \
          sudo cp "$brew_bin" /opt/socket_vmnet/bin/socket_vmnet && \
          sudo chown root:wheel /opt/socket_vmnet/bin/socket_vmnet && \
          sudo chmod 755 /opt/socket_vmnet/bin/socket_vmnet && \
          has_vmnet=true
        if [[ "$has_vmnet" == true ]]; then
          if [[ ! -e /etc/sudoers.d/lima ]]; then
            echo "Setting up Lima sudoers..."
            limactl sudoers | sudo tee /etc/sudoers.d/lima >/dev/null
          fi
        else
          echo "Failed to copy socket_vmnet binary. Bridged networking disabled."
        fi
      fi
    fi
  fi

  local config=$(mktemp /tmp/sandclip-XXXXXX)
  mv "$config" "${config}.yaml"
  config="${config}.yaml"

  # Build YAML line by line to avoid heredoc interpolation issues
  local -a yaml=(
    'vmType: vz'
    "arch: ${arch}"
    "cpus: ${cpus}"
    "memory: \"${mem_gib}GiB\""
    'disk: "50GiB"'
    ''
    'user:'
    '  name: human'
    ''
    'images:'
    "  - location: \"${image_url}\""
    "    arch: \"${arch}\""
    ''
    'mounts:'
    "  - location: \"$(pwd)\""
    '    writable: true'
    ''
  )

  if [[ "$network_mode" != "bridged" ]]; then
    yaml+=(
      'portForwards:'
      '  - guestPortRange: [3000, 3100]'
      '    hostPortRange: [3000, 3100]'
      '  - guestPortRange: [4000, 4100]'
      '    hostPortRange: [4000, 4100]'
      '  - guestPortRange: [5000, 5100]'
      '    hostPortRange: [5000, 5100]'
      '  - guestPortRange: [8000, 9000]'
      '    hostPortRange: [8000, 9000]'
    )
  fi

  yaml+=(
    ''
    'hostResolver:'
    '  enabled: false'
    'dns:'
    '  - 1.1.1.1'
    '  - 8.8.8.8'
    ''
    'containerd:'
    '  system: false'
    '  user: false'
    ''
    'vmOpts:'
    '  vz:'
    '    rosetta:'
    '      enabled: true'
    '      binfmt: true'
    ''
    'provision:'
    '  - mode: system'
    '    script: |'
    '      #!/bin/bash'
    '      set -eux -o pipefail'
    '      PRIMARY_IF=$(ip route | grep default | awk '"'"'{print $5}'"'"' | head -1)'
    '      if [ -n "$PRIMARY_IF" ]; then'
    '        ip link set "$PRIMARY_IF" mtu 1400'
    '      fi'
    '  - mode: system'
    '    script: |'
    '      #!/bin/bash'
    '      set -eux -o pipefail'
    '      if id human &>/dev/null && command -v nvim &>/dev/null; then'
    '        echo "Image already provisioned"'
    '        exit 0'
    '      fi'
    '      cd /tmp'
    '      curl -fsSL https://raw.githubusercontent.com/idpbond/config/refs/heads/master/setup-env.sh -o setup-env.sh'
    '      chmod +x setup-env.sh'
    '      TARGET_USER="$(whoami)" NONINTERACTIVE=1 ./setup-env.sh'
  )

  printf '%s\n' "${yaml[@]}" > "$config"

  echo "Creating VM '$name': ${cpus} CPUs, ${mem_gib}GiB RAM, mounting $(pwd)"
  echo "Image: ${image_url}"
  if [[ "$network_mode" == "bridged" ]]; then
    if [[ "$has_vmnet" == true ]]; then
      echo "Bridged networking: enabled"
    else
      echo "Bridged networking: requested but socket_vmnet not available (brew install socket_vmnet)"
    fi
  else
    echo "Network: default"
  fi
  local -a create_args=(create --tty=false --name="$name")
  if [[ "$network_mode" == "bridged" && "$has_vmnet" == true ]]; then
    create_args+=(--set '.networks = [{"lima": "bridged"}]')
  fi
  create_args+=("$config")
  limactl "${create_args[@]}"
  rm -f "$config"
  limactl start "$name"
  limactl shell --workdir "$(pwd)" "$name"
}

# ── main ─────────────────────────────────────────────────────────────────────

sandclip() {
  # Gather existing VMs
  local -a vm_lines vm_names vm_statuses menu_items
  local line

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    vm_lines+=("$line")
  done < <(limactl list --format '{{.Name}} {{.Status}}' 2>/dev/null | grep -v '^NAME ')

  for line in "${vm_lines[@]}"; do
    local vname="${line%% *}"
    local vstatus="${line##* }"
    vm_names+=("$vname")
    vm_statuses+=("$vstatus")
  done

  # Build menu
  if (( ${#vm_names[@]} > 0 )); then
    # Show existing VMs as selectable items, then actions
    for i in {1..${#vm_names[@]}}; do
      local st="${vm_statuses[$i]}"
      local icon="⏸"
      [[ "$st" == "Running" ]] && icon="●"
      menu_items+=("${icon} ${vm_names[$i]}  (${st})")
    done
  fi

  local default_name=$(_sandclip_default_name)
  menu_items+=("+ Create new sandbox ($default_name)")
  menu_items+=("✕ Stop and delete a VM")

  local choice
  choice=$(_sandclip_menu "Sandclip VMs (j/k to move, enter to select, q to quit):" "${menu_items[@]}") || return 0

  case "$choice" in
    "+"*)
      local config_result
      config_result=$(_sandclip_config "$default_name") || return 0
      local cfg_cpus="${config_result%%|*}"
      local cfg_rest="${config_result#*|}"
      local cfg_mem="${cfg_rest%%|*}"
      local cfg_net="${cfg_rest#*|}"
      _sandclip_create "$default_name" "$cfg_cpus" "$cfg_mem" "$cfg_net"
      ;;
    "✕"*)
      if (( ${#vm_names[@]} == 0 )); then
        echo "No VMs to delete."
        return 0
      fi
      local -a del_items
      for i in {1..${#vm_names[@]}}; do
        del_items+=("${vm_names[$i]}  (${vm_statuses[$i]})")
      done
      local del_choice
      del_choice=$(_sandclip_menu "Select VM to delete:" "${del_items[@]}") || return 0
      local del_name="${del_choice%% *}"
      echo "Stopping and deleting '$del_name'..."
      limactl stop -f "$del_name" 2>/dev/null
      limactl delete "$del_name"
      echo "Deleted '$del_name'."
      ;;
    *)
      # Selected an existing VM — extract name (format: "● name  (Status)")
      local sel_name="${choice#* }"     # strip "● "
      sel_name="${sel_name%%  \(*}"      # strip "  (Status)"
      limactl start "$sel_name" 2>/dev/null
      limactl shell --workdir "$(pwd)" "$sel_name"
      ;;
  esac
}
