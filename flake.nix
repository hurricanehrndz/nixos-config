{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs = {
    # Track channels with commits tested and built by hydra
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";

    # Flake utilities.
    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixpkgs";
    digga.inputs.darwin.follows = "darwin";
    digga.inputs.nixlib.follows = "nixpkgs";
    digga.inputs.nixpkgs-unstable.follows = "nixos-unstable";
    digga.inputs.home-manager.follows = "home-manager";
    digga.inputs.deploy.follows = "deploy";

    # System management.
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin-stable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # System tools
    snapraid-runner.url = "github:hurricanehrndz/snapraid-runner/hrndz";
    snapraid-runner.inputs.nixpkgs.follows = "nixpkgs";

    # User environments.
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Deployments.
    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets management.
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Sources management.
    nur.url = "github:nix-community/NUR";
    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixpkgs";

    # Rust tools
    naersk.url = "github:nmattia/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";

    # pypi packages
    yamllint-src = {
      url = "github:adrienverge/yamllint";
      flake = false;
    };
    yamlfixer-src = {
      url = "github:opt-nc/yamlfixer";
      flake = false;
    };
    # neovim
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    gitsigns-src = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    nvim-colorizer-src = {
      url = "github:NvChad/nvim-colorizer.lua";
      flake = false;
    };
    nvim-window-src = {
      url = "gitlab:yorickpeterse/nvim-window";
      flake = false;
    };
    nvim-osc52-src = {
      url = "github:ojroques/nvim-osc52";
      flake = false;
    };

    # tmux
    extrakto-src = {
      url = "github:laktak/extrakto";
      flake = false;
    };

    nixpkgs.follows = "nixos-stable";
  };

  outputs =
    { self
    , agenix
    , darwin
    , deploy
    , digga
    , home-manager
    , nixos-generators
    , nixos-hardware
    , nixos-stable
    , nixpkgs
    , nur
    , nvfetcher
    , snapraid-runner
    , neovim-nightly
    , ...
    } @ inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos-stable = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [ ];
        };
        nixpkgs-darwin-stable = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [ ];
        };
        nixos-unstable = { };
      };

      lib = import ./lib { lib = digga.lib // nixos-stable.lib; };

      sharedOverlays = [
        (final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (lfinal: lprev: {
            our = self.lib;
          });
        })

        agenix.overlay
        neovim-nightly.overlay
        nvfetcher.overlay
        nur.overlay
        snapraid-runner.overlays.snapraid-runner

        (import ./pkgs)
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos-stable";
          imports = [
            (digga.lib.importExportableModules ./modules/common)
            (digga.lib.importExportableModules ./modules/nixos)
          ];
          modules =
            let
              nur-modules = import nur {
                nurpkgs = nixpkgs.legacyPackages.x86_64-linux;
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
              };
            in
            [
              { lib.our = self.lib; }
              digga.nixosModules.nixConfig
              home-manager.nixosModules.home-manager
              agenix.nixosModules.age
              nur.nixosModules.nur
              snapraid-runner.nixosModules.snapraid-runner
              # { imports = [ nur-modules.repos.dukzcry.modules.cockpit ]; }
            ];
        };

        imports = [ (digga.lib.importHosts ./hosts/nixos) ];
        hosts = {
          /* set host-specific properties here */
          Lucy = { };
          DeepThought = { };
        };
        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles // {
            users = digga.lib.rakeLeaves ./users;
          };
          suites = with profiles; rec {
            base = [ common system.nixos networking.dhcp-all users.hurricane ];
            mediaserver = [ plex ];
            hardware-accel = [ hardware.opengl ];
            services-host = [ traefik ];
            remote-monitoring = [ netdata ];
          };
        };
      };

      darwin = {
        hostDefaults = {
          system = "x86_64-darwin";
          channelName = "nixpkgs-darwin-stable";
          imports = [
            (digga.lib.importExportableModules ./modules/common)
            # (digga.lib.importExportableModules ./modules/darwin)
          ];
          modules = [
            { lib.our = self.lib; }
            digga.darwinModules.nixConfig
            home-manager.darwinModules.home-manager
            agenix.nixosModules.age
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts/darwin) ];
        hosts = {
          /* set host-specific properties here */
          Mac = { };
        };
        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles // {
            users = digga.lib.rakeLeaves ./users;
          };
          suites = with profiles; rec {
            base = [ system.darwin users.darwin ];
          };
        };
      };

      home = {
        imports = [ (digga.lib.importExportableModules ./users/modules) ];
        modules = [ ];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./users/profiles;
          suites = with profiles; rec {
            base = [ zsh shellAliases direnv git tmux ];
            dev = [ nvim ];
          };
        };
        users = {
          # These only exist within the `hmUsers` attrset
          hurricane = { suites, ... }: { imports = suites.base ++ suites.dev; };
          darwin = { suites, ... }: { imports = suites.base; };
        }; # digga.lib.importers.rakeLeaves ./users/hm;
      };

      devshell = ./shell;

      # TODO: similar to the above note: does it make sense to make all of
      # these users available on all systems?
      homeConfigurations = digga.lib.mergeAny
        (digga.lib.mkHomeConfigurations self.darwinConfigurations)
        (digga.lib.mkHomeConfigurations self.nixosConfigurations)
      ;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };
    };
}
