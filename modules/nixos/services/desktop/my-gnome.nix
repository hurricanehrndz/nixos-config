{ config, lib, pkgs, options, ... }:

with lib;

let
  cfg = config.services.myGnomeDesktop;
in
{
  options.services.myGnomeDesktop = {
    enable = mkEnableOption "Enable GNOME desktop environment.";

    userName = mkOption {
      type = types.str;
      description = ''
        Primary GNOME desktop user.
      '';
    };

  };
  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
        # disable suspend on login screen
        autoSuspend = false;
      };
      # mouse and/or touchbad driver
      libinput.enable = true;
    };

    # Gnome packages
    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gedit # text editor
      epiphany # web browser
      geary # email reader
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      gnome-contacts
      gnome-initial-setup
    ]);
    programs.dconf.enable = true;

    # audio
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    hardware.pulseaudio.enable = false;

    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr # screen capture wayland
        ];
      };
    };
  };
}
