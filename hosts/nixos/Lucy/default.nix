{ pkgs, suites, self, config, ... }:

let
  authkeyFile = "${self}/secrets/services/tailscale/authkey.age";
in
{
  ### root password is empty by default ###
  imports = (with suites; base ++ hardware-accel) ++ [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  age.secrets = {
    # needs to get updated on recreating a system (exprie every 6 monts)
    "tailscale.authkey".file = authkeyFile;
  };

  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.lxd.enable = true;
  users.users.hurricane = {
    extraGroups = [ "lxd" "libvirtd" "qemu-libvirtd" ];
  };
  security.polkit.enable = true;

  environment = {
    systemPackages = with pkgs; [
      virt-manager
    ];
  };

  services = {
    myWgMesh = {
      enable = true;
      authKeyFile = config.age.secrets."tailscale.authkey".path;
    };

  };

  networking.domain = "hrndz.ca";
  # Lucy has no swap device
  zramSwap.enable = true;

  system.stateVersion = "22.05";
}
