{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.modules.defaults.fhs;
in
{
  options.modules.defaults.fhs.enable = mkEnableOption "defaults: fhs";
  config = mkIf (cfg.enable) {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = mkDefault [ ];
  };
}
