{ pkgs, lib, config, ... }:

let
  pidFile = "${config.services.plex.dataDir}/Plex Media Server/plexmediaserver.pid";
in
{
  services.plex = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.plex.serviceConfig = {
    KillSignal = lib.mkForce "SIGKILL";
    TimeoutStopSec = 10;
    ExecStop = pkgs.writeScript "plex-stop" ''
      #!${pkgs.bash}/bin/bash

      ${pkgs.procps}/bin/pkill --signal 15 --pidfile "${pidFile}"
      ${pkgs.coreutils}/bin/sleep 5
    '';
    PIDFile = lib.mkForce "";
  };
}
