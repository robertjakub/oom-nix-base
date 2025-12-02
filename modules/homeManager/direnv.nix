{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hm;
in {
  options.hm.direnv.enable = mkEnableOption "home-manager/direnv";
  config = mkIf (cfg.direnv.enable) {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = false;
      enableZshIntegration = cfg.zsh.enable;
    };
  };
}
