#!/usr/bin/env bash
set -euo pipefail

echo "=== Lix + Home Manager Installation Script ==="
echo

# Check if Lix is already installed
if command -v nix &> /dev/null; then
    echo "✓ Nix/Lix is already installed"
else
    echo "→ Installing Lix..."
    curl -sSf -L https://install.lix.systems/lix | sh -s -- install
    
    # Source Lix environment
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    
    echo "✓ Lix installed successfully"
fi

echo
echo "→ Activating home-manager configuration..."

# Navigate to the nix-config directory
cd ~/dotfiles/nix-config

# Run home-manager switch
nix run home-manager/release-25.05 -- switch --flake .#gustavo@work

echo
echo "✓ Home-manager configuration activated!"
echo
echo "Next steps:"
echo "1. Restart your shell or run: source ~/.bashrc"
echo "2. Your dotfiles are now managed by Nix/home-manager"
echo "3. To update in the future, run: home-manager switch --flake ~/dotfiles/nix-config#gustavo@work"
echo
echo "Note: You may want to backup and remove the old dotfiles from ~ that are now managed by Nix"
