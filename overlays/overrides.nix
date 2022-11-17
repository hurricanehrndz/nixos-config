channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  inherit (channels.nixos-unstable)
    cachix
    dhall
    discord
    element-desktop
    rage
    nix-index
    nixpkgs-fmt
    qutebrowser
    signal-desktop
    starship
    deploy-rs
    neovimUtils
    neovim-remote
    vimPlugins
    ;

  # nvim-window = prev.vimUtils.buildVimPluginFrom2Nix { pname = "nvim-window"; src = inputs.nvim-window-src; };
  haskellPackages = prev.haskellPackages.override
    (old: {
      overrides = prev.lib.composeExtensions (old.overrides or (_: _: { })) (hfinal: hprev:
        let version = prev.lib.replaceChars [ "." ] [ "" ] prev.ghc.version;
        in
        {
          # same for haskell packages, matching ghc versions
          inherit (channels.latest.haskell.packages."ghc${version}")
            haskell-language-server;
        });
    });
}
