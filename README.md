# Nix Configuration

This repository is home to the nix code that builds my systems.

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This
means that once something is setup and configured once, it works forever. If
someone else shares their configuration, anyone can make use of it.

This flake is configured with the use of [digga][digga].

[digga]: https://github.com/divnix/digga

## Prepping Disk

```
sudo su -
device=/dev/nvme0n1
parted $device -- mklabel gpt
parted $device -- mkpart primary 1GB -8GB
parted $device -- mkpart primary linux-swap -8GB 100%
parted $device -- mkpart ESP fat32 1MB 1GB
parted $device -- set 3 esp on
mkswap -L swap ${device}p2
mkfs.fat -F 32 -n boot ${device}p3
mkfs.btrfs -L nixos ${device}p1

mount ${device}p1 /mnt
btrfs subvolume create /mnt/@
subvols=(home var nix tmp srv opt root)
for subvol in ${subvols[@]}; do 
  echo "Creating subvol: ${subvol}..."
  btrfs subvolume create /mnt/@${subvol}
done
chattr +C /mnt/@var
btrfs subvolume set-default $(btrfs subvol list /mnt | awk '/@$/{print $2}') /mnt
umount /mnt
mount -o compress=zstd,noatime ${device}p1 /mnt
mkdir -p /mnt/{home,var,nix,tmp,srv,opt,root,boot}
for subvol in ${subvols[@]}; do 
  echo "Mounting subvol: ${subvol}..."
  mount -o compress=zstd,noatime,subvol=@${subvol} ${device}p1 /mnt/${subvol}
done
mount ${device}p3 /mnt/boot
```

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


## Setup secrets
Copy user private id_ed25519 age key to bootstrap instance, place in the usual
place `/home/hurricane/.ssh`.
```
sudo nixos-enter
ssh_keygen=$(systemctl cat sshd | awk -F'=' '/sshd-pre-start/{print $2}')
$ssh_keygen
exit
```

Update secrets.nix with the new pub key of the host, rekey, and rerun install

```
export PRIVATE_KEY=/home/hurricane/.ssh/id_25519
agenix --rekey
sudo nixos-install --root /mnt --no-root-passwd --flake "/mnt/etc/nixos#$FLAKE_HOST"
```

## Enter chroot after install

```
sudo nixos-enter
```
