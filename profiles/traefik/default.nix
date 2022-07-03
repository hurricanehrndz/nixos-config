{ self, ... }:

{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      providers.file.directory = "${config.services.traefik.dataDir}/conf.d";
      api.insecure = true;
      entryPoints = {
        web.address = ":80";
        websecure.address = ":443";
      };
      certificatesResolvers."dnsResolver".acme = {
        dnschallenge = {
          provider = "cloudflare";
          resolvers = [
            "1.1.1.1:53"
            "8.8.8.8:53"
          ];
        };
        # TRAEFIK_CERTIFICATESRESOLVERS_<NAME>_ACME_EMAIL:
        storage = "acme.json";
      };
      serversTransport.forwardingTimeouts.idleConnTimeout = "5s";
      http.middlewares = {
        "redirect-to-https" = {
          redirectscheme.scheme = https;
          redirectscheme.permanent = true;
        };
        "traefik-stripprefix" = {
          stripprefix.prefixes = "/traefik";
        };
      };
      routers = {
        # Global redirect to HTTPS
        "redirs" = {
          rule = "hostregexp=(`{host:.+}`)";
          entryPoints = [
            "web"
          ];
          middlewares = [
            "redirect-to-https"
          ];
        };
        # Route internal api
        "traefik" = {
          rule = "Host(`${hostname}.${domain_name}`) && (PathPrefix(`/traefik`) || PathPrefix(`/api`))";
          entryPoints = [
            "websecure"
          ];
          middlewares = [
            "traefik-stripprefix"
          ];
          service = "api@internal";
          tls.certresolver = "dnsResolver";
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
