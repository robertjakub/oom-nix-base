{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
  fn = import ../lib/internal.nix { inherit lib; };
in
{
  options.modules.desktop = {
    enable = lib.mkEnableOption "x11/desktop/graphics";
    wayland.enable = lib.mkEnableOption "wayland";
  };

  imports = (fn.scanPaths ./desktop);

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = cfg.enable;
      xkb.layout = "us, pl";
    };
    programs.xwayland.enable = cfg.wayland.enable;

    environment.systemPackages = with pkgs; [ gsettings-desktop-schemas ];
  };
}
