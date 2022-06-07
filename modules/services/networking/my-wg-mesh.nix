{ config, lib, pkgs, options, ... }:

with lib;

let
  cfg = config.services.MyWgMesh;
in
{
  options.services.MyWgMesh = {
    enable = mkEnableOption "Enable mesh VPN service tailscale.";

    authKeyFile = mkOption {
      type = types.str;
      description = ''
        File containing the Auth key with no formatting whatsoever
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (options ? services.tailscale.enable) {
      # see https://tailscale.com/blog/nixos-minecraft/
      # make the tailscale command usable to users
      environment.systemPackages = [ pkgs.tailscale ];

      # enable the tailscale service
      services.tailscale.enable = true;
      # create a oneshot job to authenticate to Tailscale
      systemd.services.tailscale-autoconnect = {
        description = "Automatic connection to Tailscale";

        # make sure tailscale is running before trying to connect to tailscale
        after = [ "network-pre.target" "tailscale.service" ];
        wants = [ "network-pre.target" "tailscale.service" ];
        wantedBy = [ "multi-user.target" ];

        # set this service as a oneshot job
        serviceConfig.Type = "oneshot";
        serviceConfig.TimeoutSec = 90;

        unitConfig.ConditionPathExists = "${cfg.authKeyFile}";

        # have the job run this shell script
        script = with pkgs; ''
          # wait for tailscaled to settle
          sleep 2

          # check if we are already authenticated to tailscale
          status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
          if [ $status = "Running" ]; then # if so, then do nothing
            exit 0
          fi

          # otherwise authenticate with tailscale
          ${tailscale}/bin/tailscale up -authkey $(cat ${cfg.authKeyFile})
        '';
      };

      networking.firewall = {
        # enable the firewall
        enable = true;

        # always allow traffic from your Tailscale network
        trustedInterfaces = [ "tailscale0" ];

        # allow the Tailscale UDP port through the firewall
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
    })
  ]);

}
