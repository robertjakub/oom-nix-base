{ config, lib, ... }:
let cfg = config.modules.apps;
in lib.mkIf (lib.elem "doas" cfg.apps) {
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = (map (user: "${user.name} ") config.modules.users.users) ++ [ "root" ]; #FIXME
    keepEnv = lib.mkDefault true;
    persist = lib.mkDefault true;
  }];
}
