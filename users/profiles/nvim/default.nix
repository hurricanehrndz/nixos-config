{ pkgs, lib, inputs, ... }:
let
  # Function to override the source of a package
  withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });
  yamllint = with pkgs.python3Packages; buildPythonApplication {
    name = "yamllint";
    src = inputs.yamllint-src;
    doCheck = false;
    propagatedBuildInputs = [ setuptools pyaml pathspec ];
  };
  yamlfixer = with pkgs.python3Packages; buildPythonApplication {
    name = "yamlfixer";
    src = inputs.yamlfixer-src;
    doCheck = false;
    propagatedBuildInputs = [ setuptools yamllint ];
  };
in
{

  home.packages = with pkgs; [
    beautysh
    black
    cbfmt
    lazygit
    neovim-remote
    nixpkgs-fmt
    nodePackages.markdownlint-cli
    nodePackages.prettier
    puppet-lint
    ripgrep
    shellcheck
    shfmt
    stylua
    swift
    vale
    yamlfixer
    yamllint
  ];

  programs.lazygit = {
    enable = true;
    settings = {
      promptToReturnFromSubprocess = false;
      os = {
        editCommand = "nvr -s -l"; # see 'Configuring File Editing' section
        editCommandTemplate = "{{editor}} +{{line}} -- {{filename}}";
        openCommand = "nvr -s -l {{filename}}";
      };
      git = {
        autorefresh = false;
      };
      keybinding = {
        files = {
          commitChanges = "C";
          commitChangesWithEditor = "c";
        };
      };
    };
  };

  programs.zsh.initExtra = ''
    if [[ -n "$NVIM" || -n "$NVIM_LISTEN_ADDRESS" ]]; then
      export EDITOR="nvr -l"
      export VISUAL="nvr --remote-tab-silent"
      alias vi="nvr -l"
      alias vim="nvr -l"
      alias nvim="nvr -l"
      alias v="nvr -l"
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
      # lsp
      rnix-lsp
      sumneko-lua-language-server
    ];
    extraConfig = ''
      lua << EOF
      -- Sensible defaults - mine
      require("hrndz.options")

      -- Key mappings
      require("hrndz.keymaps")
      -- Autocmds
      require("hrndz.autocmds")
      EOF


    '';
    plugins = with pkgs.vimPlugins;
      let
        nvim-window = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "nvim-window";
          src = inputs.nvim-window-src;
          version = "master";
        };
        nvim-osc52 = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "nvim-osc52";
          src = inputs.nvim-osc52-src;
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
        telescope-file-browser-nvim

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
              tree-sitter-help
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
        # what's did I do wrong
        {
          plugin = trouble-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.trouble")
          '';
        }
        # add completion
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            require("hrndz.plugins.completion")
          '';
        }
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        cmp-buffer
        cmp-cmdline

        # snippets
        luasnip
        cmp_luasnip
        friendly-snippets
        vim-snippets

        # formatters, linters
        null-ls-nvim

        # add lsp config
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            require("hrndz.lsp")
          '';
        }
        neodev-nvim

        # nice plugins
        nvim-osc52
        vim-tmux-navigator
        nvim-notify
        undotree
        {
          plugin = feline-nvim;
          type = "lua";
          config = ''
            require("hrndz.plugins.feline")
          '';
        }
        {
          plugin = nvim-surround;
          type = "lua";
          config = ''
            require("hrndz.plugins.surround")
          '';
        }
        {
          plugin = vim-better-whitespace;
          type = "lua";
          config = ''
            require("hrndz.plugins.whitespace")
          '';
        }

        # pictograms
        lspkind-nvim
      ];
  };
  xdg.configFile = {
    "nvim" = {
      recursive = true;
      source = ./config;
    };
  };
}
