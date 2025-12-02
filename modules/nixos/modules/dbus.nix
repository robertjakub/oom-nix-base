{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.defaults.dbus;
in
{
  options.modules.defaults.dbus.enable = mkEnableOption "Simple interprocess messaging system";
  config = mkIf cfg.enable { services.dbus.enable = true; };
}
