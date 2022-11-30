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

    # quick cd
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";

    # Git
    g = "git";
    ga = "git add";
    gaa = "git add --all";
    # Git commit
    gc = "git commit --verbose";
    gcs = "git commit --verbose --sign";
    gca = "git commit --verbose --amend";
    gcaa = "git commit --verbose --amend --all";

    gd = "git diff";
    gdc = "git diff --cached";

    gco = "git checkout";
    gcm = "git checkout master";

    gst = "git status";
    gss = "git status --short";

    grh = "git reset";
    grhh = "git reset --hard";

    gf = "git fetch";
    # a pull, is a fetch and merge
    gfm = "git pull";

    gp = "git push";
    gpF = "git push --force";
    gpf = "git push --force-with-lease";
    gpc = "git push --set-upstream origin HEAD";

    # git clone
    gcl = "git clone --recursive-submodules";

    # Git rebase sign commits
    grsc = "git rebase --exec 'git --amend --no-edit -n -S' -i";

    gl = "git log --topo-order --pretty=format:'%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'";
    glb = "git log --topo-order --pretty=format:'%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n'";
    glg = "git log --topo-order --all --graph --pretty=format:'%C(green)%h%C(reset) %s%C(red)%d %C(reset)%C(blue)Sig:%G?%C(reset)%n'";

    # virsh
    virsh = "virsh --connect='qemu:///system'";
    virt-install = "virt-install --connect 'qemu:///system'";
  };
}
