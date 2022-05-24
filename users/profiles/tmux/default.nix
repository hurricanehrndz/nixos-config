{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    keyMode = "vi";
    terminal = "screen-256color";
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.power-theme;
        extraConfig = "set -g @themepack 'powerline/block/orange'";
      }
    ];
  };
}
