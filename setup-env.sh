#!/bin/bash
set -e

# Configuration variables (can be overridden via environment)
NODE_VERSION="${NODE_VERSION:-24.4.1}"
DEBIAN_VERSION="${DEBIAN_VERSION:-trixie-slim}"
TARGET_USER="${TARGET_USER:-human}"
# Set NONINTERACTIVE=0 to enable interactive commands (e.g., exec newgrp at the end)
NONINTERACTIVE="${NONINTERACTIVE:-1}"
# Set SKIP_DOCKER=1 to skip Docker installation (e.g., in container builds)
SKIP_DOCKER="${SKIP_DOCKER:-0}"
# Set SKIP_SNAP=1 to skip snapd/certbot installation (e.g., in container builds)
SKIP_SNAP="${SKIP_SNAP:-0}"

echo "Starting development environment setup..."

# Verify Debian/Ubuntu distribution
if [ -f /etc/debian_version ]; then
    echo "Detected Debian/Ubuntu Linux"
else
    echo "Unsupported Linux distribution (only Debian/Ubuntu is supported)"
    exit 1
fi

# Check if running as root
if [ "$EUID" -eq 0 ] || [ "$(id -u)" -eq 0 ] || [ "$USER" = "root" ] || [ "$(whoami)" = "root" ]; then
   echo "Running as root user"
   IS_ROOT=true
else
   echo "Running as non-root user: $USER"
   IS_ROOT=false
fi

# Install sudo first if running as root (needed for subsequent operations)
if [ "$IS_ROOT" = true ]; then
    echo "Installing sudo first..."
    apt-get update
    apt-get install -y --no-install-recommends sudo
fi

# Update package list and install dependencies
echo "Updating package list..."
if [ "$IS_ROOT" = true ]; then
    apt-get update
else
    sudo apt-get update
fi

echo "Installing system dependencies..."
PACKAGES="openssl curl wget git tar lua5.4 bash zsh golang ripgrep ninja-build gettext less man-db cmake unzip ruby ruby-dev tmux lazygit build-essential fzf python3 python3.13-venv neovim ca-certificates gnupg lsb-release rsync htop btm ffmpeg imagemagick libvips ncdu jq"

if [ "$IS_ROOT" = true ]; then
    apt-get install -y --no-install-recommends --ignore-missing $PACKAGES || {
        echo "Retrying after apt-get update..."
        apt-get update && apt-get install -y --no-install-recommends --ignore-missing $PACKAGES
    }
    update-ca-certificates
else
    sudo apt-get install -y --no-install-recommends --ignore-missing $PACKAGES || {
        echo "Retrying after apt-get update..."
        sudo apt-get update && sudo apt-get install -y --no-install-recommends --ignore-missing $PACKAGES
    }
    sudo update-ca-certificates
fi

if [ "$SKIP_DOCKER" != "1" ]; then
# Install Docker from Debian repos (more reliable than official Docker repo)
echo "Installing Docker..."
# Remove any leftover Docker repo config that may cause apt to hang
if [ "$IS_ROOT" = true ]; then
    rm -f /etc/apt/sources.list.d/docker.list
    rm -f /etc/apt/keyrings/docker.asc
    apt-get update
    apt-get install -y docker.io docker-compose
else
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo rm -f /etc/apt/keyrings/docker.asc
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose
fi
fi

if [ "$SKIP_SNAP" != "1" ]; then
# Install snapd and certbot with route53 plugin
echo "Installing snapd and certbot..."
if [ "$IS_ROOT" = true ]; then
    apt-get install -y snapd
    # Ensure snapd is running
    systemctl enable --now snapd.socket || true
    # Install core snap first (required for classic snaps)
    snap install core || true
    # Install certbot
    snap install --classic certbot || true
    # Create symlink for certbot
    ln -sf /snap/bin/certbot /usr/bin/certbot || true
    # Trust plugin with root BEFORE installing the plugin
    snap set certbot trust-plugin-with-root=ok || true
    # Install certbot-dns-route53 plugin
    snap install certbot-dns-route53 || true
    # Connect the plugin to certbot
    snap connect certbot:plugin certbot-dns-route53 || true
else
    sudo apt-get install -y snapd
    sudo systemctl enable --now snapd.socket || true
    sudo snap install core || true
    sudo snap install --classic certbot || true
    sudo ln -sf /snap/bin/certbot /usr/bin/certbot || true
    # Trust plugin with root BEFORE installing the plugin
    sudo snap set certbot trust-plugin-with-root=ok || true
    sudo snap install certbot-dns-route53 || true
    sudo snap connect certbot:plugin certbot-dns-route53 || true
fi
fi

# Clean apt cache
if [ "$IS_ROOT" = true ]; then
    rm -rf /var/lib/apt/lists/*
else
    sudo rm -rf /var/lib/apt/lists/*
fi

# Install asdf
echo "Installing asdf..."
cd /tmp
# Clean up any previous download attempts
rm -f asdf.tar.gz asdf
# Detect architecture
ASDF_ARCH=""
case "$(uname -m)" in
    x86_64)  ASDF_ARCH="amd64" ;;
    aarch64) ASDF_ARCH="arm64" ;;
    armv7l)  ASDF_ARCH="arm" ;;
    *)       echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac
echo "Detected architecture: $(uname -m) -> downloading asdf-v0.18.0-linux-${ASDF_ARCH}.tar.gz"
wget "https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-${ASDF_ARCH}.tar.gz" -O asdf.tar.gz
tar xzf asdf.tar.gz
echo "Extracted binary: $(file asdf)"
if [ "$IS_ROOT" = true ]; then
    rm -f /usr/local/bin/asdf
    mv asdf /usr/local/bin/
else
    sudo rm -f /usr/local/bin/asdf
    sudo mv asdf /usr/local/bin/
fi
rm -f asdf.tar.gz
cd -

# Update rubygems (only if running as root to avoid permission issues)
if [ "$IS_ROOT" = true ]; then
    echo "Updating rubygems..."
    gem install rubygems-update && update_rubygems
fi

# Create 'human' user if running as root (after all system packages are installed)
if [ "$IS_ROOT" = true ]; then
    if ! id "$TARGET_USER" &>/dev/null; then
        echo "Creating user: $TARGET_USER..."
        useradd -m -s /bin/zsh "$TARGET_USER"
        # Add to docker group
        if [ "$SKIP_DOCKER" != "1" ]; then
            usermod -aG docker "$TARGET_USER"
        fi
        # Add human to sudoers with full privileges
        echo "$TARGET_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    else
        echo "User $TARGET_USER already exists"
        # Ensure user has sudo privileges
        echo "$TARGET_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
        # Ensure user is in docker group
        if [ "$SKIP_DOCKER" != "1" ]; then
            usermod -aG docker "$TARGET_USER" || true
        fi
    fi
    echo "Switching to $TARGET_USER for remaining setup..."
    # Copy script to a location accessible by the new user
    SCRIPT_PATH="$0"
    TEMP_SCRIPT="/tmp/setup-env-user.sh"
    cp "$SCRIPT_PATH" "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    chown "$TARGET_USER:$TARGET_USER" "$TEMP_SCRIPT"
    su - "$TARGET_USER" -c "bash -c 'cd /tmp && SKIP_DOCKER=$SKIP_DOCKER SKIP_SNAP=$SKIP_SNAP NONINTERACTIVE=$NONINTERACTIVE bash $TEMP_SCRIPT --user-setup'"
    exit 0
fi

# User-specific setup (runs as human user or existing non-root user)
if [ "$1" = "--user-setup" ] || [ "$IS_ROOT" = false ]; then
    echo "Running user-specific setup for user: $USER..."

    if [ "$SKIP_DOCKER" != "1" ]; then
        # Add user to docker group for sudo-less docker access
        echo "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER" || echo "Could not add to docker group (may need to log out and back in)"
    fi

    # Change default shell to zsh
    echo "Setting zsh as default shell..."
    sudo chsh -s /bin/zsh "$USER" || echo "Could not change shell to zsh"

    # Install oh-my-zsh
    echo "Installing oh-my-zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || echo "Oh-my-zsh installation failed"
    else
        echo "Oh-my-zsh already installed"
    fi

    # Configure asdf and install Node.js
    echo "Configuring asdf..."
    echo 'export PATH="$HOME/.asdf/shims:$PATH"' >> ~/.zshrc
    echo 'autoload -Uz compinit && compinit' >> ~/.zshrc

    # Source zshrc to get asdf in current session
    export PATH="$HOME/.asdf/shims:$PATH"

    # Install Node.js via asdf
    echo "Installing Node.js $NODE_VERSION..."
    asdf plugin add nodejs || echo "nodejs plugin already added"
    asdf install nodejs $NODE_VERSION
    asdf set --home nodejs $NODE_VERSION

    # Install Agentic Code CLIs
    echo "Installing claude-code..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "Installing codex cli..."
    npm i -g @openai/codex
    echo "Installing gemini cli..."
    npm i -g @google/gemini-cli

    # Install mise
    echo "Installing mise..."
    curl https://mise.run | bash

    export PATH="~/.local/bin:~/go/bin:/snap/bin:$PATH"

    # Install lazydocker
    echo "Installing lazydocker..."
    go install github.com/jesseduffield/lazydocker@latest

    echo "Installing aws-cli..."
    if [ "$SKIP_SNAP" != "1" ] && command -v snap &>/dev/null; then
        sudo snap install aws-cli --classic
    else
        python3 -m pip install --break-system-packages awscli
    fi

    # Configure fzf and locale
    echo "Configuring environment..."
    echo 'source <(fzf --zsh)' >> ~/.zshrc
    echo "export LC_ALL=C.UTF-8" >> ~/.zshrc
    echo "export LANG=C.UTF-8" >> ~/.zshrc
    
    # Download and setup tmux configuration
    echo "Downloading tmux configuration..."
    curl -fsSL https://raw.githubusercontent.com/idpbond/config/refs/heads/master/.tmux.conf -o ~/.tmux.conf || echo "Failed to download .tmux.conf"

    # Setup Neovim configuration
    echo "Setting up Neovim configuration..."
    if [ ! -d ~/.config/nvim ]; then
        git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
        rm -rf ~/.config/nvim/.git
    fi
    mkdir -p ~/.config/nvim/lua/plugins/
    echo "Downloading custom.lua..."
    curl -fsSL https://raw.githubusercontent.com/idpbond/config/refs/heads/master/nvim/custom.lua -o ~/.config/nvim/lua/plugins/custom.lua || echo "Failed to download custom.lua"

    echo "Installing Neovim plugins..."
    nvim -n --headless '+Lazy install' +qall || echo "Lazy install may have failed"
    nvim -n --headless '+LspInstall lua_ls ts_ls yamlls tailwindcss rubocop eslint elixirls cssls bashls' +qall || echo "LspInstall may have failed"
    nvim -n --headless '+TSInstallSync! typescript html css javascript ruby python go dockerfile yaml json' +qall || echo "TSInstall may have failed"
    
    # Set terminal environment variables
    echo "export TERM=xterm-256color" >> ~/.zshrc
    echo "export COLORTERM=24bit" >> ~/.zshrc

    # Prepend hostname to prompt (e.g., [sandbox-zxc])
    echo 'PROMPT="%F{cyan}[%m]%f $PROMPT"' >> ~/.zshrc

    # Setup SSH authorized_keys
    echo "Setting up SSH access..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDITNF2OzvDUD6Jw+agvqP59fOnVDnH1Nu0uxYTQdB7+EqBuTmAd42Fd26bqhWSdYd+Vnxhb2amXu5cm9tjooEpBjRNkHGmmHZsObCzZTLt7y3U0sq7n5wWr5Id4lhQhpSzRTNXqQab6UIyfpRoi4qR08Ef89yPsfzRuJHQ2YzwcCeIlojI1ic+OWFOfC94aIQmOpwGghAtbCpF7aj6x0NWFO3e5hp4na3CGX0ZOItQY/bKCsdlpZ9u4X5c+BhvKHNzuswq6bVhP01gMzd63iX+KCPLLZDQIswvPJjfjy33DDVwhXewJAiOF1m8CbRvZp4NBIVvZ7042buk6kd1kPB/O2/h+tt9DWdLbLyiXecUvVxZ8Tmdckyl+scahScHSBlNP8lB2ezUm+Al+DQDWwzaemYzrJC9c5BtmJ11iEUQyVpPpItdNc7EygY9whQ53KkITOqjPh5cRKolrn7+BEt/Ohhjhazfnlax8Z2W5dB17N4aTA7m2+ZrwVF2Inkzp8c= ilia@BONDmacbook
EOF
    chmod 600 ~/.ssh/authorized_keys

    if [ "$NONINTERACTIVE" = "1" ]; then
        echo "Setup complete!"
    elif [ "$SKIP_DOCKER" != "1" ]; then
        echo "Setup complete! Starting new shell with docker group access..."
        exec newgrp docker
    else
        echo "Setup complete!"
    fi
fi
