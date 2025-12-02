{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault mkForce;
  gnome = config.services.desktopManager.gnome.enable;
in
{
  networking = {
    inherit (config.modules) domain;
    enableIPv6 = mkDefault false;
    useDHCP = mkDefault true;
    wireless.enable = mkDefault false;
    networkmanager.enable = mkIf (!gnome) false;
    resolvconf.enable = mkDefault true;
  };

  services.resolved.enable = mkForce false;
}
