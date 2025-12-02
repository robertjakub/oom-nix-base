{ config, lib, ... }:
let cfg = config.modules.apps;
in lib.mkIf (lib.elem "neovim" cfg.apps) {
  programs.neovim = {
    enable = true;
    defaultEditor = lib.mkDefault true;
    viAlias = lib.mkDefault true;
    vimAlias = lib.mkDefault true;
  };
}
