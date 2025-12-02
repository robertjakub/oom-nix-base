{ config, lib, ... }:
let cfg = config.modules.apps;
in lib.mkIf (lib.elem "mtr" cfg.apps) {
  programs.mtr.enable = true;
}
