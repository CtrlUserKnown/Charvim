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
    DISTRO_LIKE=""
    if [[ "$(uname -s)" == "Darwin" ]]; then
        DISTRO="macos"
        return
    fi
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="${ID,,}"
        DISTRO_LIKE="${ID_LIKE,,}"
    fi
}

# 5. Install dependencies — one function per package manager

install_deps_macos() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install it from https://brew.sh and re-run."
        exit 1
    fi
    local pkgs=(neovim git ripgrep fd python3 make node)
    local bins=(nvim git rg fd python3 make node)
    local missing_pkgs=()
    for i in "${!pkgs[@]}"; do
        command -v "${bins[$i]}" &>/dev/null || missing_pkgs+=("${pkgs[$i]}")
    done
    [[ ${#missing_pkgs[@]} -eq 0 ]] && return
    run_step \
        "Installing dependencies (${missing_pkgs[*]})" \
        "installed: ${missing_pkgs[*]}" \
        "brew install ${missing_pkgs[*]} &>/dev/null"
}

install_deps_fedora() {
    local pkgs=(neovim git ripgrep fd-find python3 make nodejs)
    local bins=(nvim git rg fd python3 make node)
    local missing_pkgs=()
    for i in "${!pkgs[@]}"; do
        command -v "${bins[$i]}" &>/dev/null || missing_pkgs+=("${pkgs[$i]}")
    done
    [[ ${#missing_pkgs[@]} -eq 0 ]] && return
    run_step \
        "Installing dependencies (${missing_pkgs[*]})" \
        "installed: ${missing_pkgs[*]}" \
        "sudo dnf install -y ${missing_pkgs[*]} &>/dev/null"
}

install_deps_debian() {
    local pkgs=(neovim git ripgrep fd-find python3 make nodejs)
    local bins=(nvim git rg fdfind python3 make node)
    local missing_pkgs=()
    for i in "${!pkgs[@]}"; do
        command -v "${bins[$i]}" &>/dev/null || missing_pkgs+=("${pkgs[$i]}")
    done
    [[ ${#missing_pkgs[@]} -eq 0 ]] && return
    run_step \
        "Updating package lists" \
        "package lists updated" \
        "sudo apt-get update -qq &>/dev/null"
    run_step \
        "Installing dependencies (${missing_pkgs[*]})" \
        "installed: ${missing_pkgs[*]}" \
        "sudo apt-get install -y ${missing_pkgs[*]} &>/dev/null"
}

install_deps_arch() {
    local pkgs=(neovim git ripgrep fd python make nodejs)
    local bins=(nvim git rg fd python3 make node)
    local missing_pkgs=()
    for i in "${!pkgs[@]}"; do
        command -v "${bins[$i]}" &>/dev/null || missing_pkgs+=("${pkgs[$i]}")
    done
    [[ ${#missing_pkgs[@]} -eq 0 ]] && return
    run_step \
        "Installing dependencies (${missing_pkgs[*]})" \
        "installed: ${missing_pkgs[*]}" \
        "sudo pacman -S --noconfirm ${missing_pkgs[*]} &>/dev/null"
}

install_gum
detect_distro

if [[ -n "$GUM" ]]; then
    clear
    $GUM style --foreground 212 --bold "CharVim Installation"
    echo ""
fi

if [[ "$DISTRO" == "macos" ]]; then
    install_deps_macos
elif [[ "$DISTRO" == "fedora" ]] || [[ "$DISTRO_LIKE" == *"fedora"* ]]; then
    install_deps_fedora
elif [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]] || [[ "$DISTRO_LIKE" == *"debian"* ]]; then
    install_deps_debian
elif [[ "$DISTRO" == "arch" ]] || [[ "$DISTRO_LIKE" == *"arch"* ]]; then
    install_deps_arch
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
