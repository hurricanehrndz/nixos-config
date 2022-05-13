{ config, lib, self, ... }:

{
  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks = {
      "99-en-dhcp" = {
        matchConfig.Name = "en*";
        networkConfig.DHCP = "yes";
      };
    };
  };
}
