{ config, profiles, lib, modulesPath, self, ... }:

{
  # build with: `nix build ".#nixosConfigurations.bootstrap.config.system.build.isoImage"`
  imports = [
    # profiles.networking
    profiles.common
    profiles.system.nixos
    profiles.users.root # make sure to configure ssh keys
    profiles.users.hurricane
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.loader.systemd-boot.enable = true;

  # will be overridden by the bootstrapIso instrumentation
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };


  isoImage.isoBaseName = "bootstrap-nixos";
  isoImage.contents = [{
    source = self;
    target = "/etc/nixos/";
  }];
  isoImage.storeContents = [
    self.devShell.${config.nixpkgs.system}
    # include also closures that are "switched off" by the
    # above profile filter on the local config attribute
    config.system.build.toplevel
  ] ++ builtins.attrValues self.inputs;
  # still pull in tools of deactivated profiles

  # confilcts with profiles.system.nixos  which might be slightly
  # more useful on a stick
  services.openssh.permitRootLogin = lib.mkForce "yes";

  # confilcts with networking.wireless which might be slightly
  # more useful on a stick
  networking.networkmanager.enable = lib.mkForce false;
  # confilcts with networking.wireless
  networking.wireless.iwd.enable = lib.mkForce false;

  # Set up a link-local boostrap network
  # See also: https://github.com/NixOS/nixpkgs/issues/75515#issuecomment-571661659
  networking.usePredictableInterfaceNames = lib.mkForce true; # so prefix matching works
  networking.useNetworkd = lib.mkForce true;
  networking.useDHCP = lib.mkForce false;
  networking.dhcpcd.enable = lib.mkForce false;
  systemd.network = {
    # https://www.freedesktop.org/software/systemd/man/systemd.network.html
    networks."boostrap-link-local" = {
      matchConfig = {
        Name = "en* wl* ww*";
      };
      networkConfig = {
        Description = "Link-local host bootstrap network";
        MulticastDNS = true;
        LinkLocalAddressing = "ipv6";
        DHCP = "yes";
      };
      address = [
        # fall back well-known link-local for situations where MulticastDNS is not available
        "fe80::47" # 47: n=14 i=9 x=24; n+i+x
      ];
      extraConfig = ''
        # Unique, yet stable. Based off the MAC address.
        IPv6LinkLocalAddressGenerationMode = "eui64"
      '';
    };
  };
}
