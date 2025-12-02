{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hm;
in {
  options.hm.tmux.enable = mkEnableOption "home-manager/tmux";
  config = mkIf (cfg.tmux.enable) {
    programs.tmux = {
      enable = true;
      terminal = "xterm-256color";
      secureSocket = false;
    };
  };
}
