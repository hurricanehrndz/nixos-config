{ config, lib, pkgs, options, ... }:

with lib;
# Wrapper for nixpkgs traefik module with cook in personal defaults
# see: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-servers/traefik.nix
# Traekik: file and directory provider are mutually exclusive, wrapping to enable directory
let
  cfg = config.services.myTraefikProxy;
  dynamicConfDir = "${config.services.traefik.dataDir}/conf.d";
  jsonValue = with types;
    let
      valueType = nullOr
        (oneOf [
          bool
          int
          float
          str
          (lazyAttrsOf valueType)
          (listOf valueType)
        ]) // {
        description = "JSON value";
        emptyValue.value = { };
      };
    in
    valueType;
  # copy/pasta from nixpkgs
  staticConfigFile = pkgs.runCommand "config.toml"
    {
      buildInputs = [ pkgs.yj ];
      preferLocalBuild = true;
    } ''
    yj -jt -i \
      < ${
        pkgs.writeText "static_config.json" (builtins.toJSON
          (recursiveUpdate cfg.staticConfigOptions {
            providers.file.directory = "${dynamicConfDir}";
          }))
      } \
      > $out
  '';
  # copy/pasta from nixpkgs
  traefikDynamicConfigFile = configOptions: pkgs.runCommand "config.toml"
    {
      buildInputs = [ pkgs.remarshal ];
      preferLocalBuild = true;
    } ''
    remarshal -if json -of toml \
      < ${
        pkgs.writeText "dynamic_config.json"
        (builtins.toJSON configOptions)
      } \
      > $out
  '';
in
{
  options.services.myTraefikProxy = with types; {
    enable = mkEnableOption "personal Traefik proxy";

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Environment file (see <literal>systemd.exec(5)</literal>
        "EnvironmentFile=" section for the syntax) to define variables for
        Traefik. This option can be used to safely include secret keys into the
        Traefik configuration.
      '';
    };
    staticConfigOptions = mkOption {
      description = ''
        Static configuration for personal Traefik proxy.
      '';
      type = jsonValue;
      example = {
        entryPoints.web.address = ":8080";
        entryPoints.http.address = ":80";
        api = { };
      };
      default = {
        log = {
          level = "DEBUG";
        };
        serversTransport.forwardingTimeouts.idleConnTimeout = "5s";
        api = {
          insecure = true;
        };
        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entrypoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure.address = ":443";
        };
        certificatesResolvers.dnsResolver.acme = {
          dnschallenge = {
            provider = "cloudflare";
            resolvers = [
              "1.1.1.1:53"
              "8.8.8.8:53"
            ];
          };
          # TRAEFIK_CERTIFICATESRESOLVERS_<NAME>_ACME_EMAIL:
          storage = "${config.services.traefik.dataDir}/acme.json";
        };
      };
    };
    mainDynamicConfigOptions = mkOption {
      description = ''
        Main dynamic configuration for Traefik.
      '';
      type = jsonValue;
      example = {
        http.routers.router1 = {
          rule = "Host(`localhost`)";
          service = "service1";
        };

        http.services.service1.loadBalancer.servers =
          [{ url = "http://localhost:8080"; }];
      };
      default = {
        http.middlewares = {
          traefik-stripprefix = {
            stripPrefix.prefixes = [
              "/traefik"
            ];
          };
        };
        http.routers = {
          # Route internal api
          traefik = with config.networking; {
            rule = "Host(`${hostName}.${domain}`) && (PathPrefix(`/traefik`) || PathPrefix(`/api`))";
            entryPoints = [
              "websecure"
            ];
            middlewares = [
              "traefik-stripprefix"
            ];
            service = "api@internal";
            tls.certResolver = "dnsResolver";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d '${dynamicConfDir}' 0700 traefik traefik - -" ];
    services.traefik = {
      enable = true;
      staticConfigFile = "${staticConfigFile}";
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    systemd.services.traefik =
      let
        mainDynamicConfigFile = traefikDynamicConfigFile cfg.mainDynamicConfigOptions;
      in
      {
        preStart = ''
          ln -sf ${mainDynamicConfigFile} ${dynamicConfDir}/main.toml
        '';
      } // optionalAttrs (cfg.environmentFile != null) {
        serviceConfig.EnvironmentFile = cfg.environmentFile;
      };
  };
}
