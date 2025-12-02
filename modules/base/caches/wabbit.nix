{ config, lib, ... }:
let cfg = config.modules;
in lib.mkIf (lib.elem "wabbit" cfg.caches) {
  nix.settings = {
    substituters = [ "https://cache-nix.project2.xyz/uconsole" ];
    trusted-substituters = [ "https://cache-nix.project2.xyz/uconsole" ];
    trusted-public-keys = [ "uconsole:vvqOLjqEwTJBUqv1xdndD1YHcdlMc/AnfAz4V9Hdxyk=" ];
  };
}
