{ config, pkgs, lib, ... }:
let cfg = config.modules.desktop.gnome;
in {
  options.modules.desktop.gnome.enable = lib.mkEnableOption "gnome";

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [ pkgs.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']

        [org/gnome/settings-daemon/plugins/power]
        sleep-inactive-ac-timeout=0
        sleep-inactive-ac-type="nothing"
        power-button-action="suspend"

        [org/gnome/desktop/interface]
        clock-format="12h"
        color-scheme="prefer-dark"
        gtk-theme="Adwaita-dark"
      '';
    };

    environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-remote-desktop ];

    environment.systemPackages =
      [ pkgs.gnome-tweaks pkgs.adwaita-qt pkgs.adwaita-qt6 ]
      ++ [ pkgs.gnome-session ]
      ++ [ pkgs.solarc-gtk-theme ]
      ++ [ pkgs.gnomeExtensions.brightness-control-using-ddcutil ]
      ++ [ pkgs.ddcutil ]
      ++ (lib.optionals config.services.tailscale.enable
        [ pkgs.gnomeExtensions.tailscale-qs pkgs.gnomeExtensions.tailscale-status ]);

    environment.variables = {
      QT_QPA_PLATFORMTHEME = lib.mkDefault "gnome";
      # QT_QPA_PLATFORM = lib.mkDefault "wayland";
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
      # GTK_THEME = "Adwaita:dark";
    };

    environment.etc = {
      "xdg/gtk-2.0/gtkrc".text = ''
        gtk-theme-name = "Adwaita-dark"
        gtk-icon-theme-name = "Adwaita"
      '';
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name = Adwaita-dark
        gtk-application-prefer-dark-theme = true
        gtk-icon-theme-name = Adwaita
      '';
      "xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name = Adwaita-dark
        gtk-application-prefer-dark-theme = true
        gtk-icon-theme-name = Adwaita
        gtk-hint-font-metrics = true
      '';
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
  };
}
