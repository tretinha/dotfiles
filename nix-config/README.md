# Nix Dotfiles Configuration

This repository contains my dotfiles managed with [Lix](https://lix.systems/) and [home-manager](https://github.com/nix-community/home-manager).

## Configurations

### Gaming PC (NixOS)

- **Host:** `gaming`
- **OS:** NixOS with Jovian (SteamOS-like configuration)
- **Config:** `hosts/gaming/`

### Work PC (Ubuntu + Nix)

- **Host:** `work` (gustavo-Precision)
- **OS:** Ubuntu 22.04 (managed with Nix, not NixOS)
- **Config:** `hosts/work/`

## Installation

### First Time Setup (Work PC)

1. Clone this repository to `~/dotfiles`:

   ```bash
   git clone https://github.com/tretinha/dotfiles.git ~/dotfiles
   ```

2. Run the installation script:

   ```bash
   cd ~/dotfiles/nix-config
   ./install.sh
   ```

3. Restart your shell:
   ```bash
   exec bash
   ```

### Manual Installation

If you prefer manual installation:

1. Install Lix:

   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

2. Source Lix environment:

   ```bash
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   ```

3. Activate home-manager:
   ```bash
   cd ~/dotfiles/nix-config
   nix run home-manager/release-25.05 -- switch --flake .#gustavo@work
   ```

## Updating Configuration

After making changes to your configuration files:

```bash
cd ~/dotfiles/nix-config
home-manager switch --flake .#gustavo@work
```

Or from anywhere:

```bash
home-manager switch --flake ~/dotfiles/nix-config#gustavo@work
```

## Structure

```
nix-config/
├── flake.nix              # Main flake configuration with Lix
├── nixos.nix              # NixOS configurations
├── home-manager.nix       # Standalone home-manager configurations
├── modules/
│   └── common.nix         # Common NixOS settings
├── hosts/
│   ├── gaming/            # Gaming PC (NixOS)
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
│   └── work/              # Work PC (Ubuntu + Nix)
│       └── home.nix
└── config/                # Dotfiles and configurations
    ├── nvim/              # Neovim config
    ├── openbox/           # Openbox WM config
    ├── systemd/           # Systemd user services
    ├── tint2/             # Tint2 panel config
    ├── themes/            # Custom themes
    ├── scripts/           # Custom scripts
    └── .tmux.conf         # Tmux config
```

## Managed Components (Work PC)

- **Shell:** Bash with Atuin history, FZF
- **Editor:** Neovim (existing setup symlinked)
- **Terminal Multiplexer:** Tmux
- **Window Manager:** Openbox
- **Compositor:** Picom
- **Panel:** Tint2
- **Development:** Git, work-specific tools
- **Systemd Services:** Auto-sync, invoice generator

## Packages Installed

See `hosts/work/home.nix` for the complete list of packages managed by Nix.

## Customization

### Adding Packages

Edit `hosts/work/home.nix` and add packages to `home.packages`:

```nix
home.packages = with pkgs; [
  # Add your package here
  neofetch
];
```

### Modifying Bash Configuration

Edit the `programs.bash` section in `hosts/work/home.nix`.

### Adding New Config Files

1. Add the file to `config/`
2. Create a symlink in `home.file` or `xdg.configFile` in `hosts/work/home.nix`

## Why Lix?

[Lix](https://lix.systems/) is a modern fork of Nix with better error messages, improved performance, and active development. It's fully compatible with the Nix ecosystem while providing a better user experience.

## Migration Notes

This configuration was migrated from a traditional dotfiles setup (managed in `~` via git) to a Nix-based approach. All configurations from the old setup have been preserved and are now declaratively managed.

### Old Setup

- Dotfiles tracked directly in `~` via git
- Manual package installation
- Systemd services manually configured

### New Setup

- All configs in `~/dotfiles/nix-config`
- Packages declaratively installed via Nix
- Configurations symlinked from Nix store
- Reproducible across machines

## Troubleshooting

### Lix not found after installation

Source the Lix environment:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Add this to your shell rc file if needed (though home-manager should handle this).

### Conflicts with existing dotfiles

Backup and remove conflicting files from `~`:

```bash
mv ~/.bashrc ~/.bashrc.backup
mv ~/.config/nvim ~/.config/nvim.backup
```

Then re-run home-manager switch.

### Updates not applying

Make sure you're in the correct directory and the flake is up to date:

```bash
cd ~/dotfiles/nix-config
nix flake update
home-manager switch --flake .#gustavo@work
```

## License

Personal dotfiles - use at your own discretion.
