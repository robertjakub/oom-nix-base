{ config, lib, ... }:
let cfg = config.modules.desktop;
in {
  options.modules.desktop.gnome = {
    gdm = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (cfg.gnome.enable && cfg.gnome.gdm) {
    # services.xserver.enable = true;
    # services.xserver.displayManager.defaultSession = mkIf (!cfg.gdm) null;
    services.xserver.displayManager.gdm = {
      enable = true;
      autoSuspend = lib.mkDefault false;
      wayland = lib.mkForce cfg.wayland.enable;
    };
  };
}
