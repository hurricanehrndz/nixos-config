{ pkgs, extraModulesPath, inputs, lib, ... }:
let

  inherit (pkgs)
    agenix
    cachix
    editorconfig-checker
    mdbook
    nixUnstable
    nixpkgs-fmt
    nvfetcher-bin
    rage
    ;

  hooks = import ./hooks;

  pkgWithCategory = category: package: { inherit package category; };
  devos = pkgWithCategory "devos";
  linter = pkgWithCategory "linter";
  docs = pkgWithCategory "docs";

in
{
  _file = toString ./.;

  imports = [ "${extraModulesPath}/git/hooks.nix" ];
  git = { inherit hooks; };

  commands = [
    (devos nixUnstable)
    (devos agenix)
    (devos inputs.deploy.packages.${pkgs.system}.deploy-rs)
    (devos rage)

    {
      category = "devos";
      name = nvfetcher-bin.pname;
      help = nvfetcher-bin.meta.description;
      command = "cd $PRJ_ROOT/pkgs; ${nvfetcher-bin}/bin/nvfetcher -c ./sources.toml $@";
    }

    (linter nixpkgs-fmt)
    (linter editorconfig-checker)

    (docs mdbook)
  ]
  ++ lib.optional (!(pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64))
    (devos cachix)
  ++ lib.optional (pkgs.stdenv.hostPlatform.isLinux && !pkgs.stdenv.buildPlatform.isDarwin)
    (devos inputs.nixos-generators.defaultPackage.${pkgs.system})
  ;
}
