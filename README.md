# Nix Configuration

This repository is home to the nix code that builds my systems.

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This
means that once something is setup and configured once, it works forever. If
someone else shares their configuration, anyone can make use of it.

This flake is configured with the use of [digga][digga].

[digga]: https://github.com/divnix/digga

## Install

Install without secrets:
```
# Prep drive, and mount on /mnt, then
export FLAKE_HOST="Lucy"
sudo nixos-generate-config --root /mnt
sudo cp -r /mnt/etc/nixos ~/
sudo rm -rf /mnt/etc/nixos
sudo git clone https://github.com/hurricanehrndz/nixos-config.git /mnt/etc/nixos
sudo cp ~/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/nixos/$FLAKE_HOST/hardware-configuration.nix
sudo nix flake update /mnt/etc/nixos
sudo nixos-install --root /mnt --no-root-passwd --flake "/mnt/etc/nixos#$FLAKE_HOST"

# After booting system, if ownership of /etc/nixos is changed, run:
sudo git config --global --add safe.directory /etc/nixos
# or run builds with
nixos-rebuild switch --use-remote-sudo
```

