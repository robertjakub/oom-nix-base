{ config, lib, ... }:
let
  inherit (lib) mkIf elem;
  cfg = config.modules.users;
  users = map (user: "${user.name}") cfg.users;
in
mkIf (elem "toor" users) {
  security.sudo.extraRules = [
    {
      users = [ "toor" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];
}
