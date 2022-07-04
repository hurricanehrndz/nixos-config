{ self, config, ... }:

let
  dynamicConfDir = "${config.services.traefik.dataDir}/conf.d";
in
{
  systemd.tmpfiles.rules = [ "d '${dynamicConfDir}' 0700 traefik traefik - -" ];
  services.traefik = {
    enable = true;
    staticConfigOptions = {
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
    dynamicConfigOptions = {
      http.middlewares = {
        redirect-to-https = {
          redirectscheme.scheme = "https";
          redirectscheme.permanent = true;
        };
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

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  age.secrets = {
    "traefik.env".file = "${self}/secrets/services/traefik/env.age";
  };

  systemd.services.traefik.serviceConfig = {
    EnvironmentFile = config.age.secrets."traefik.env".path;
  };
}
