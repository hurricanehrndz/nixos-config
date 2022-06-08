{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    vimAlias = true;
    viAlias = true;
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

          vim.keymap.set("n", "<C-p>", require("telescope.builtin").git_files)
          vim.keymap.set("n", "<space>ff", require("telescope.builtin").find_files)
        '';
      }
      plenary-nvim
      popup-nvim
      telescope-fzf-native-nvim
    ];
  };
}
