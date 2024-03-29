{ config, lib, pkgs, self, ... }:

{
  nix = {
    # This is just a representation of the nix default
    settings = {
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      # Improve nix store disk usage
      auto-optimise-store = true;
      allowed-users = [ "@wheel" ];
    };
    optimise.automatic = true;
  };

  environment = {

    # Selection of sysadmin tools that can come in handy
    systemPackages = with pkgs; [
      dosfstools
      git-crypt
      gptfdisk
      iputils
      parted
      usbutils
      utillinux
      pciutils
    ];

  };


  i18n.defaultLocale = "en_US.UTF-8";

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = lib.mkOverride 500 "no";
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  programs = {
    command-not-found.enable = true;
    bash = {
      shellAliases = {
        l = "exa -lh --group-directories-first -F --icons";
        la = "exa -aalhF --group-directories-first --icons";
        lt = "exa --tree --icons -d -a --ignore-glob '**/.git'";
        tm = "tmux new-session -A -s main";
        type = "type -a";
        mkdir = "mkdir -p";
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
      terminal = "tmux-256color";
    };
  };

  # Service that makes Out of Memory Killer more effective
  services.earlyoom.enable = true;
}
