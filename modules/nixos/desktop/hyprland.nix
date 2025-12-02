{ config, pkgs, lib, inputs, ... }:
let cfg = config.modules.desktop.hyprland;
in {
  options.modules.desktop.hyprland.enable = lib.mkEnableOption "Hyprland";

  config = lib.mkIf cfg.enable {
    modules.security.polkit.enable = lib.mkDefault true;
    modules.defaults.dbus.enable = lib.mkDefault true;

    xdg.portal = {
      enable = true;
      wlr.enable = lib.mkDefault true;
      xdgOpenUsePortal = lib.mkDefault false;
      extraPortals = with pkgs; [
        # xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };

    programs = {
      hyprland = {
        enable = true;
        xwayland = { enable = true; };
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        # portalPackage = pkgs.xdg-desktop-portal-hyprland;
      };
    };

    services.picom.enable = true;
    security.pam.services.swaylock = { };
    security.pam.services.swaylock.fprintAuth = false;

    environment.systemPackages = with pkgs; [
      kitty
      kanshi
      waybar
      hyprshot
      hyprpaper
      swayidle
      swaylock-effects
      nwg-look
      brightnessctl
      wlogout
      wofi
      wl-clipboard
      libnotify
      mako
      adwaita-icon-theme
      xfce.thunar
      hypridle
      hyprlock
    ];
  };
}
