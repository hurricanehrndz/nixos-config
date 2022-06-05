{ suites, self, ... }:

{
  ### root password is empty by default ###
  imports = (with suites; base ++ mediaserver) ++ [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  age.secrets = {
    "hosts/lucy/ssh_host_ed25519_key" = {
      file = "${self}/secrets/hosts/lucy/ssh_host_ed25519_key.age";
      path = "/etc/ssh/ssh_host_ed25519_key";
      symlink = false;
    };
    "hosts/lucy/ssh_host_ed25519_key.pub" = {
      file = "${self}/secrets/hosts/lucy/ssh_host_ed25519_key.pub.age";
      path = "/etc/ssh/ssh_host_ed25519_key.pub";
      symlink = false;
    };
  };

  # Lucy has no swap device
  zramSwap.enable = true;

  system.stateVersion = "22.05";
}
