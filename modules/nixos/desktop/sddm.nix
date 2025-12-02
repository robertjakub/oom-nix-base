{ config, lib, pkgs, ... }:
let cfg = config.modules.desktop;
in {
  options.modules.desktop.sddm.enable = lib.mkEnableOption "enable sddm";

  config = lib.mkIf (cfg.sddm.enable) {
    environment.systemPackages = with pkgs; [
      (where-is-my-sddm-theme.override {
        variants = [ "qt6" ];
        themeConfig.General = {
          background = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          backgroundMode = "none";
          blurRadius = 75;
        };
      })
    ];
    # services.displayManager.defaultSession = "hyprland";
    services.displayManager.sddm = {
      enable = true;
      theme = "where_is_my_sddm_theme";
      wayland.enable = lib.mkForce cfg.wayland.enable;
      # wayland.compositor = "kwin"; # FIXME
    };
  };
}
