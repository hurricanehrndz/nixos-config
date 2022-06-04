{ config, lib, pkgs, self, ... }:

{
  # This is just a representation of the nix default
  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

  environment = {

    # Selection of sysadmin tools that can come in handy
    systemPackages = with pkgs; [
      dosfstools
      gptfdisk
      iputils
      usbutils
      utillinux
    ];

  };

  nix = {
    # Improve nix store disk usage
    autoOptimiseStore = true;
    optimise.automatic = true;
    allowedUsers = [ "@wheel" ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = lib.mkOverride 500 "no";
  };

  programs = {
    bash = {
      shellAliases = {
        l="exa -lh --group-directories-first -F --icons";
        la = "exa -aalhF --group-directories-first --icons";
        lt = "exa --tree --icons -d -a --ignore-glob '**/.git'";
        tm = "tmux new-session -A -s main";
        type="type -a";
        mkdir="mkdir -p";
      };
      # Enable starship
      promptInit = ''
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
      interactiveShellInit = ''
        source "${pkgs.fzf}/share/fzf/key-bindings.bash"
      '';
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      shortcut = "a";
      terminal = "screen-256color";
    };
  };

  # Service that makes Out of Memory Killer more effective
  services.earlyoom.enable = true;
}
