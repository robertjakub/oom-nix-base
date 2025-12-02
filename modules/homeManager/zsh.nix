{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hm;
in {
  options.hm.zsh.enable = mkEnableOption "home-manager/ssh";
  config = mkIf (cfg.zsh.enable) {
    programs.zsh.enable = true;
    programs.zsh.completionInit = "autoload -U compinit && compinit -u";
  };
}
