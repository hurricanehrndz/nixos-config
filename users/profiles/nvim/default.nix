{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    vimAlias = true;
    viAlias = true;
    extraPackages = with pkgs; [
      ripgrep
    ];
    extraConfig = ''
      lua require('hrndz.settings')
    '';
    plugins = with pkgs.vimPlugins; [
      {
        plugin = tokyonight-nvim;
        type = "lua";
        config = ''
          if vim.fn["has"]("termguicolors") then
            vim.o.termguicolors = true
          end

          vim.o.background = "dark"
          vim.cmd("syntax on")

          require("tokyonight")
          vim.g.tokyonight_style = "night"
          vim.g.tokyonight_italic_functions = true
          vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }

          -- Load the colorscheme
          vim.cmd([[colorscheme tokyonight]])
        '';
      }
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
      vim-polyglot
    ];
  };
  xdg.configFile = {
    "nvim" = {
      recursive = true;
      source = ./config;
    };
  };
}
