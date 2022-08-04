{ pkgs, ... }:

{

  home.packages = with pkgs; [
    lazygit
    neovim-remote
  ];

  programs.zsh.initExtra = ''
    if [[ -n "$NVIM" || -n "$NVIM_LISTEN_ADDRESS" ]]; then
      alias vi="nvr -l"
      alias vim="nvr -l"
      alias nvim="nvr -l"
    fi
  '';

  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    vimAlias = true;
    viAlias = true;
    extraPackages = with pkgs; [
      ripgrep
    ];
    extraConfig = ''
      lua require("hrndz.settings")
    '';
    plugins = with pkgs.vimPlugins; [
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
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require("hrndz.plugins.gitsigns")
        '';
      }
      {
        plugin = nvim-colorizer-lua;
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
      vim-polyglot
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
