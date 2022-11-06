{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 10;
    extraConfig = ''
      set-option -sa terminal-overrides ',*256col*:RGB'
      bind r source-file $HOME/.config/tmux/tmux.conf \; display "TMUX conf reloaded!"
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.power-theme;
        extraConfig = "set -g @themepack 'powerline/block/orange'";
      }
    ];
  };
}
