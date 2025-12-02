{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.defaults.i2c;
in
{
  options.modules.defaults.i2c.enable = mkEnableOption "defaults: i2c";
  config = mkIf (cfg.enable) {
    hardware.i2c.enable = true;
    environment.systemPackages = with pkgs; [ lm_sensors i2c-tools ];
    boot.kernelModules = [ "i2c-dev" ];
  };
}
