{ config, lib, ... }:
let
  cfg = config.modules.users;

  users = user: {
    inherit (user) name;
    value = lib.mkIf (lib.elem "hm" user.tags) {
      home.enableNixpkgsReleaseCheck = lib.mkDefault false;
      hm.zsh.enable = lib.mkDefault true;
      hm.ssh.enable = lib.mkDefault true;
      hm.direnv.enable = lib.mkDefault true;
      hm.tmux.enable = lib.mkDefault true;
    };
  };
in
{
  config = lib.mkIf cfg.enable {
    home-manager.backupFileExtension = lib.mkDefault "pre-hm";
    home-manager.users = lib.listToAttrs (map users cfg.users);
  };
}
