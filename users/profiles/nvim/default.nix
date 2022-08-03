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
        config = (
          builtins.readFile ./config/lua/hrndz/plugins/tokyonight.lua
        );
      }
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = ''
          local g = vim.g
          g.indent_blankline_space_char = " "
          g.indent_blankline_space_char_blankline = " "
          g.indent_blankline_char = "┊"
          g.indent_blankline_filetype_exclude = { "help", "packer" }
          g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
          g.indent_blankline_char_highlight = "LineNr"
          g.indent_blankline_show_first_indent_level = false
        '';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          local gitsigns = require("gitsigns")

          gitsigns.setup({
            keymaps = {
              -- Default keymap options
              noremap = true,
              buffer = true,

              ["n ]c"] = { expr = true, [[&diff ? "]c" : '<cmd>lua require("gitsigns").next_hunk()<CR>']] },
              ["n [c"] = { expr = true, [[&diff ? "[c" : '<cmd>lua require("gitsigns").prev_hunk()<CR>']] },

              ["n <space>hs"] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
              ["n <space>hu"] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
              ["n <space>hr"] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
              ["n <space>hR"] = '<cmd>lua require("gitsigns").reset_buffer()<CR>',
              ["n <space>hp"] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
              ["n <space>hb"] = '<cmd>lua require("gitsigns").blame_line()<CR>',

              -- Text objects
              ["o ih"] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
              ["x ih"] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
            },
          })
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
          local telescope = require("telescope")
          telescope.load_extension("fzf")

          -- search for current word under cursor
          vim.keymap.set("n", "<space>fw", function()
            return require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
          end)
          vim.keymap.set("n", "<space>fs", require("telescope.builtin").grep_string)
          vim.keymap.set("n", "<space>fg", require("telescope.builtin").live_grep)


          vim.keymap.set("n", "<C-p>", require("telescope.builtin").git_files)
          vim.keymap.set("n", "<space>ff", require("telescope.builtin").find_files)

          -- buffer finder
          vim.keymap.set("n", "<space>fb", require("telescope.builtin").buffers)

          -- help finder
          vim.keymap.set("n", "<space>fh", require("telescope.builtin").help_tags)

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
          local ts_configs = require("nvim-treesitter.configs")

          ts_configs.setup({
            ensure_installed = {},
            indent = { enable = true },
            highlight = { enable = true, },
            additional_vim_regex_highlighting = false,
            rainbow = { enable = true, extended_mode = true },
          })
        '';

      }

      # functionality
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = (
          builtins.readFile ./config/lua/hrndz/plugins/toggleterm.lua
        );
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
