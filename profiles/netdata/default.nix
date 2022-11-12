{ pkgs, lib, ... }:

{
  services.netdata = {
    enable = true;
    configDir."python.d.conf" = pkgs.writeText "python.d.conf" ''
      samba: yes
    '';
  };
  # add samba and sudo to path of python plugin
  systemd.services.netdata = {
    path = [ pkgs.samba "/run/wrappers" ];
  };
  # permit to run sudo smbstatus -P
  security.sudo.extraConfig = ''
    netdata ALL=(root) NOPASSWD: ${pkgs.samba}/bin/smbstatus
  '';
  # as documented here : https://learn.netdata.cloud/docs/agent/collectors/python.d.plugin/samba
  # but seem not to work
  systemd.services.netdata.serviceConfig = {
    CapabilityBoundingSet = [
      "CAP_SETGID" # allow sudo
      "CAP_NET_ADMIN" # bandwidtch accounting
      "CAP_SYS_RAWIO"
      "CAP_PERFMON"
    ];
    PrivateTmp = lib.mkForce false;
  };
  networking.firewall.allowedTCPPorts = [ 19999 ];
}
