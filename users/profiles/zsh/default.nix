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
      # Esc-S to insert sudo in front of command
      function prepend-sudo { # Insert "sudo " at the beginning of the line
        if [[ $BUFFER != "sudo "* ]]; then
          BUFFER="sudo $BUFFER"; CURSOR+=5
        fi
      }
      zle -N prepend-sudo

      # Note: requires vi key bindings in zsh!
      bindkey -M vicmd '^Xs' prepend-sudo
      bindkey -M viins '^Xs' prepend-sudo

      autoload -U edit-command-line
      zle -N edit-command-line

      bindkey   -M   viins   '^Y'      autosuggest-accept
      bindkey   -M   vicmd   '^X^E'    edit-command-line
      bindkey   -M   viins   '^X^E'    edit-command-line
      bindkey   -M   viins   '^P'      history-search-backward
      bindkey   -M   viins   '^N'      history-search-forward
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
