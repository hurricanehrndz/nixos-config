{ suites, self, config, ... }:

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
    "tailscale.authkey".file = "${self}/secrets/services/tailscale/authkey.age";
    "deepthought-rw.creds".file = "${self}/secrets/remote-fs/deepthouht-rw.creds.age";
  };

  services.MyWgMesh = {
    enable = true;
    authKeyFile = config.age.secrets."tailscale.authkey".path;
  };
  # Lucy has no swap device
  zramSwap.enable = true;

  system.stateVersion = "22.05";
}
