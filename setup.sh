#!/bin/bash
set -e

echo "=== Ubuntu Machine Setup ==="

# --- Claude Code ---
echo ""
echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

# --- uv ---
echo ""
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# --- zoxide (z command) ---
echo ""
echo "Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
grep -q 'eval "$(zoxide init bash)"' ~/.bashrc || echo 'eval "$(zoxide init bash)"' >> ~/.bashrc

# --- gcc (needed for Treesitter) ---
echo ""
echo "Installing gcc..."
sudo apt-get update
sudo apt-get install -y gcc

# --- tmux config ---
echo ""
echo "Configuring tmux..."
grep -q 'set -g mouse on' ~/.tmux.conf 2>/dev/null || echo 'set -g mouse on' >> ~/.tmux.conf

# --- SSH + GitHub ---
echo ""
echo "Setting up GitHub SSH..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "mylesheller@icloud.com" -f ~/.ssh/id_ed25519 -N ""
else
    echo "SSH key already exists, skipping generation."
fi

echo ""
echo "========================================="
echo "Your public key:"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""
echo "Add it here: https://github.com/settings/ssh/new"
echo "========================================="
echo ""
read -p "Press Enter once you've added the key to GitHub..."

# Test the connection
ssh -T git@github.com || true

# --- Neovim ---
echo ""
echo "Installing Neovim (latest stable)..."
sudo apt-get remove -y neovim 2>/dev/null || true
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
grep -q '/opt/nvim-linux-x86_64/bin' ~/.bashrc || echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# --- Neovim config ---
echo ""
echo "Cloning Neovim config..."
if [ -d ~/.config/nvim ]; then
    echo "~/.config/nvim already exists, skipping clone."
else
    git clone git@github.com:zarSou9/kickstart.nvim.git ~/.config/nvim
fi

echo ""
echo "=== Setup complete! ==="
echo "Run 'source ~/.bashrc' or open a new shell to apply PATH and alias changes."
echo "Launch 'nvim' to install plugins."
