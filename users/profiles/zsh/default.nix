{  pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    defaultKeymap = "viins";
    enableCompletion = true;
    autocd = true;
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignorePatterns = [ "rm *" "pkill *" ];
    };
    plugins = [
      {
        name = "ohmyzsh-git";
        file = "share/oh-my-zsh/plugins/git/git.plugin.zsh";
        src = pkgs.oh-my-zsh;
      }
      {
        name = "autosuggestions";
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "fast-syntax-highlighting";
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
    ];
    initExtraBeforeCompInit = ''
      function prepend_sudo {
        if [[ "$BUFFER" != su(do|)\ * ]]; then
          BUFFER="sudo $BUFFER"
          (( CURSOR += 5 ))
        fi
      }
      zle -N prepend_sudo

      autoload -U edit-command-line
      zle -N edit-command-line

      bindkey   -M   viins   '\C-X\C-S'      prepend_sudo
      bindkey   -M   viins   '\C-Y'          autosuggest-accept
      bindkey   -M   vicmd   '\C-X\C-E'      edit-command-line
      bindkey   -M   viins   '\C-X\C-E'      edit-command-line
      bindkey '^P' history-beginning-search-backward
      bindkey '^N' history-beginning-search-forward
    '';
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
