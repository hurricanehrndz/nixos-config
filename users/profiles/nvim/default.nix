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
    ];
  };
}
