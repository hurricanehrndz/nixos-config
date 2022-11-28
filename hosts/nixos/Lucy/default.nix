{ suites, self, config, ... }:

{
  ### root password is empty by default ###
  imports = (with suites; base ++ hardware-accel) ++ [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  age.secrets = {
    # needs to get updated on recreating a system (exprie every 6 monts)
    "tailscale.authkey".file = "${self}/secrets/services/tailscale/authkey.age";
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
