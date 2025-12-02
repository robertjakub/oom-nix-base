{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hm;
in {
  options.hm.ssh = {
    enable = mkEnableOption "home-manager/ssh";
  };
  config = mkIf (cfg.ssh.enable) {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        hashKnownHosts = false;
        serverAliveInterval = 60;
        compression = true;
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
      # userKnownHostsFile = "~/.ssh/known_hosts.d/%k";
      # extraConfig = ''
      # '';
    };
  };
}
