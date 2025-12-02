{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.modules.users;
in
{
  config = mkIf cfg.enable {
    users.users.root.openssh.authorizedKeys.keys = cfg.rootkeys;
  };
}
