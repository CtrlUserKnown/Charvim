#!/usr/bin/env bash

# --- CharVim: Install Script ---
# Author: CtrlUserUnknown
# GitHub: www.github.com/CrtlUserKnown

REPO_URL="https://github.com/CrtlUserKnown/Charvim.git"
CONFIG_DIR="$HOME/.config"
CHARVIM_DIR="$CONFIG_DIR/charvim"
GUM_TEMP_PATH="/tmp/gum"

# Variables for rollback
CREATED_DIR=""
CREATED_LINK=""
BACKUP_MADE=""

# 1. Cleanup/Rollback on Interrupt
cleanup() {
    echo -e "\n\033[31mInstallation cancelled. Rolling back...\033[0m"
    
    [[ -n "$CREATED_LINK" && -L "$CREATED_LINK" ]] && rm "$CREATED_LINK"
    if [[ -n "$BACKUP_MADE" && -d "$BACKUP_MADE" ]]; then
        mv "$BACKUP_MADE" "${BACKUP_MADE%.bak.*}"
    fi
    [[ -n "$CREATED_DIR" && -d "$CREATED_DIR" ]] && rm -rf "$CREATED_DIR"
    [[ "$GUM" == "$GUM_TEMP_PATH" ]] && rm -f "$GUM_TEMP_PATH"
    
    exit 1
}
trap cleanup SIGINT SIGTERM

# 2. Temporary gum installation
install_gum() {
    if command -v gum &>/dev/null; then
        GUM="gum"
        return
    fi
    if [[ -f "$GUM_TEMP_PATH" ]]; then
        GUM="$GUM_TEMP_PATH"
        return
    fi
    OS=$(uname -s); ARCH=$(uname -m)
    [[ "$ARCH" == "x86_64" ]] && ARCH="x86_64"
    [[ "$ARCH" == "arm64" ]] && ARCH="arm64"
    GUM_URL=$(curl -s https://api.github.com/repos/charmbracelet/gum/releases/latest | grep -o "https://.*gum_${OS}_${ARCH}.tar.gz" | head -n 1)
    if [[ -n "$GUM_URL" ]]; then
        curl -sL "$GUM_URL" -o /tmp/gum.tar.gz
        tar -xzf /tmp/gum.tar.gz -C /tmp gum
        GUM="/tmp/gum"
        rm /tmp/gum.tar.gz
    else
        GUM=""
    fi
}

# 3. Helper for same-line updates
# Usage: run_step "Initial Title" "Final Result Text" "Command"
run_step() {
    local title="$1"
    local result="$2"
    local cmd="$3"

    if [[ -n "$GUM" ]]; then
        $GUM spin --spinner dots --title " $title" -- bash -c "$cmd"
        echo -e "\033[1A\033[K  $result"
    else
        echo -n "$title... "
        eval "$cmd"
        echo "Done."
        echo "  $result"
    fi
}

# 4. Distro detection
detect_distro() {
    DISTRO=""
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="${ID,,}"
        DISTRO_LIKE="${ID_LIKE,,}"
    fi
}

# 5. Install dependencies for Fedora
install_deps_fedora() {
    local pkgs="neovim git ripgrep fd-find python3"
    local missing=()

    for pkg in $pkgs; do
        local bin="${pkg/fd-find/fd}"
        bin="${bin/neovim/nvim}"
        command -v "$bin" &>/dev/null || missing+=("$pkg")
    done

    [[ ${#missing[@]} -eq 0 ]] && return

    run_step \
        "Installing dependencies (${missing[*]})" \
        "installed: ${missing[*]}" \
        "sudo dnf install -y ${missing[*]} &>/dev/null"
}

install_gum
detect_distro

if [[ -n "$GUM" ]]; then
    clear
    $GUM style --foreground 212 --bold "CharVim Installation"
    echo ""
fi

if [[ "$DISTRO" == "fedora" ]] || [[ "$DISTRO_LIKE" == *"fedora"* ]]; then
    install_deps_fedora
fi

# Step: ~/.config
if [[ ! -d "$CONFIG_DIR" ]]; then
    run_step "Preparing directory" "directory: $CONFIG_DIR" "mkdir -p '$CONFIG_DIR'"
fi

# Step: Source Detection — remote URL check dropped intentionally.
# Presence of .git and nvim/ in the working directory is sufficient.
IS_CLONED=false
if [[ -d ".git" ]] && [[ -d "nvim" ]]; then
    IS_CLONED=true
    SOURCE_DIR="$(pwd)"
fi

# Step: Handle Files
if [[ "$IS_CLONED" == "true" ]]; then
    run_step "Checking source" "local source detected: $SOURCE_DIR" "true"
else
    if [[ -d "$CHARVIM_DIR" ]]; then
        run_step "Updating repository" "updated repository: $CHARVIM_DIR" "git -C '$CHARVIM_DIR' pull &>/dev/null"
    else
        run_step "Cloning repository" "cloned to: $CHARVIM_DIR" "git clone '$REPO_URL' '$CHARVIM_DIR' &>/dev/null"
        CREATED_DIR="$CHARVIM_DIR"
    fi
    SOURCE_DIR="$CHARVIM_DIR"
fi

# Step: Backup
if [[ -L "$CONFIG_DIR/nvim" ]] || [[ -d "$CONFIG_DIR/nvim" ]]; then
    BACKUP_DIR="$CONFIG_DIR/nvim.bak.$(date +%Y%m%d_%H%M%S)"
    run_step "Backing up config" "backup created: $BACKUP_DIR" "mv '$CONFIG_DIR/nvim' '$BACKUP_DIR'"
    BACKUP_MADE="$BACKUP_DIR"
fi

# Step: Symlink
run_step "Linking files" "linked: $SOURCE_DIR/nvim -> $CONFIG_DIR/nvim" "ln -s '$SOURCE_DIR/nvim' '$CONFIG_DIR/nvim'"
CREATED_LINK="$CONFIG_DIR/nvim"

# Step: Cleanup gum
if [[ "$GUM" == "$GUM_TEMP_PATH" ]]; then
    run_step "Finishing" "cleaned up temporary files" "rm '$GUM_TEMP_PATH'"
fi

if [[ -n "$GUM" ]]; then
    echo ""
    $GUM style --foreground 82 --bold "CharVim Installation Complete!"
else
    echo -e "\nCharVim Installation Complete!"
fi
