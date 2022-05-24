{
  home.shellAliases = {
    l = "exa -lh --group-directories-first -F --icons";
    la = "exa -aalhF --group-directories-first --icons";
    lt = "exa --tree --icons -d -a --ignore-glob '**/.git'";
    tm = "tmux new-session -A -s main";
    cat = "bat";
    type = "type -a";
    rg = "rg -i -L";
    vimdiff = "nvim -d";
    mkdir = "mkdir -p";
  };
}
