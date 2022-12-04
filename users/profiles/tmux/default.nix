{ pkgs, inputs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    keyMode = "vi";
    terminal = "tmux-256color";
    aggressiveResize = true;
    escapeTime = 10;
    extraConfig = ''
      set -g set-clipboard on
      set-option -sa terminal-overrides ',*256col*:RGB'
      bind r source-file $HOME/.config/tmux/tmux.conf \; display "TMUX conf reloaded!"

      # begin selection with v, yank with y
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'select-pane -L'
      bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'select-pane -D'
      bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'select-pane -U'
      bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'select-pane -R'

      bind-key -T copy-mode-vi 'M-h' select-pane -L
      bind-key -T copy-mode-vi 'M-j' select-pane -D
      bind-key -T copy-mode-vi 'M-k' select-pane -U
      bind-key -T copy-mode-vi 'M-l' select-pane -R

      # easily rotate window
      bind-key -n 'M-o' rotate-window

      # easily zoom
      bind-key -n 'M-z' resize-pane -Z
    '';
    plugins = with pkgs; with tmuxPlugins;
      let
        extrakto = mkTmuxPlugin {
          pluginName = "extrakto";
          version = "master";
          src = inputs.extrakto-src;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postInstall = ''
            for f in extrakto.sh open.sh; do
              wrapProgram $target/scripts/$f \
                --prefix PATH : ${with pkgs; lib.makeBinPath (
                [ pkgs.fzf pkgs.python3 pkgs.xclip ]
                )}
            done
          '';
        };
      in
      [
        {
          plugin = power-theme;
          extraConfig = "set -g @themepack 'powerline/block/orange'";
        }
        {
          plugin = extrakto;
          extraConfig = ''
            set -g @extrakto_clip_tool_run "tmux_osc52"
            set -g @extrakto_clip_tool "tmux_osc52"
            set -g @extrakto_popup_size "65%"
            set -g @extrakto_grab_area "window 500"
          '';
        }
      ];
  };
}
