{ config, lib, pkgs, self, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  # Sets nrdxp.cachix.org binary cache which just speeds up some builds
  imports = [ ../cachix ];

  time.timeZone = "America/Edmonton";

  environment = {
    pathsToLink = [ "/share/zsh" ];
    variables = {
      EDITOR = "vim";
      KERNEL_NAME =
        if pkgs.stdenv.isDarwin
        then "darwin"
        else "linux";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };
    # Selection of sysadmin tools that can come in handy
    systemPackages = with pkgs; [
      bashInteractive
      bat
      binutils
      bottom
      coreutils
      curl
      ddrescue
      direnv
      dnsutils
      exa
      fd
      gawk
      git
      gnumake
      gnupg
      gnused
      gnutar
      grc
      hyperfine
      jq
      moreutils
      nmap
      ripgrep
      fzf
      tealdeer
      whois

      nix-index
      fup-repl
      manix
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix = {
    # Improve nix store disk usage
    gc.automatic = true;

    settings = {
      # Prevents impurities in builds
      sandbox = lib.mkDefault (!isDarwin);
      # Give root user and wheel group special Nix privileges.
      trusted-users = [ "root" "@wheel" ];
    };

    # Generally useful nix option defaults
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
  };
}
