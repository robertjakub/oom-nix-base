{ config, lib, pkgs, ... }:
let cfg = config.modules.apps;
in
lib.mkIf (lib.elem "wireshark" cfg.apps) {
  environment.systemPackages = [ pkgs.wireshark ];
  homebrew.casks = [ "wireshark-chmodbpf" ];
}
