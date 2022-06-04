{ suites, ... }:
{
  ### root password is empty by default ###
  imports = (with suites; base ++ mediaserver) ++ [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Lucy has no swap device
  zramSwap.enable = true;

  system.stateVersion = "22.05";
}
