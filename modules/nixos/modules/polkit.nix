{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.security.polkit;
in
{
  options.modules.security.polkit.enable = mkEnableOption "security/polkit";

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    security.polkit.enable = true;
    environment.systemPackages = with pkgs; [
      polkit
      polkit_gnome
    ];
  };
}
