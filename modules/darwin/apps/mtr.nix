{ config, lib, pkgs, ... }:
let cfg = config.modules.apps;
in
lib.mkIf (lib.elem "mtr" cfg.apps) {
  environment.systemPackages = [ pkgs.mtr ];
}
