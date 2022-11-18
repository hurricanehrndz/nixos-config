{ pkgs, lib, inputs, ... }:
let
  # Function to override the source of a package
  withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });
in
{

  home.packages = with pkgs; [
    lazygit
    neovim-remote
  ];

  programs.lazygit = {
    enable = true;
    settings = { };
  };

  programs.zsh.initExtra = ''
    if [[ -n "$NVIM" || -n "$NVIM_LISTEN_ADDRESS" ]]; then
      alias vi="nvr -l"
      alias vim="nvr -l"
      alias nvim="nvr -l"
    fi
    alias v="nvim"
  '';

  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    vimAlias = true;
    viAlias = true;
    package = pkgs.neovim-nightly;
    extraPackages = with pkgs; [
      # used to compile tree-sitter grammar
      tree-sitter
      gcc
      ripgrep
    ];
    extraConfig = ''
      lua require("hrndz.options")
    '';
    plugins = with pkgs.vimPlugins;
      let
        nvim-window = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "nvim-window";
          src = inputs.nvim-window-src;
          version = "master";
        };
      in
      [
        # Theme
        {
          plugin = tokyonight-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.tokyonight")
          '';
        }
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.indentblankline")
          '';
        }
        {
          plugin = (withSrc gitsigns-nvim inputs.gitsigns-src);
          type = "lua";
          config = ''
            require("hrndz.plugins.gitsigns")
          '';
        }
        {
          plugin = (withSrc nvim-colorizer-lua inputs.nvim-colorizer-src);
          type = "lua";
          config = ''
            colorizer = require("colorizer")
            colorizer.setup()
          '';
        }
        {
          plugin = nvim-web-devicons;
          type = "lua";
          config = ''
            local devicons = require("nvim-web-devicons")
            devicons.setup({ default = true })
          '';
        }
        # Fuzzy finder
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.telescope")
          '';
        }
        plenary-nvim
        popup-nvim
        telescope-fzf-native-nvim

        # add some syntax highlighting
        nvim-ts-rainbow
        {
          plugin = (nvim-treesitter.withPlugins (
            plugins: with plugins; [
              tree-sitter-bash
              tree-sitter-javascript
              tree-sitter-lua
              tree-sitter-make
              tree-sitter-markdown
              tree-sitter-nix
              tree-sitter-python
              tree-sitter-typescript
              tree-sitter-tsx
            ]
          ));
          type = "lua";
          config = ''
            require("hrndz.plugins.treesitter")
          '';
        }
        # functionality
        {
          plugin = toggleterm-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.toggleterm")
          '';
        }
        # comment
        {
          plugin = comment-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.comment")
          '';
        }
        {
          plugin = nvim-window;
          type = "lua";
          config = ''
            require("hrndz.plugins.winpicker")
          '';
        }
        # which key did I just hit
        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.whichkey")
          '';
        }
        # add completion


      ];
  };
  xdg.configFile = {
    "nvim" = {
      recursive = true;
      source = ./config;
    };
  };
}
