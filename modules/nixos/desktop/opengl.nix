{ config, lib, ... }:
let cfg = config.modules.desktop;
in {
  options.modules.desktop.opengl.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf (cfg.enable && cfg.opengl.enable) {
    hardware.graphics.enable = true;
    # hardware.graphics.enable32Bit = true;
  };
}
