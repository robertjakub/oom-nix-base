{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.defaults.tape;
in
{
  options.modules.defaults.tape.enable = mkEnableOption "defaults: tape";
  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [ mt-st lsiutil hdparm pv lsscsi mbuffer ];
  };
}
