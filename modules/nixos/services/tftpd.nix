{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
in
{
  options.modules.services.tftpd = {
    enable = mkOption {
      type = types.bool;
      default = elem "tftpd" cfg.services;
      description = "enable atftpd";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "atftpd: open default ports";
    };
    root = mkOption {
      type = types.str;
      default = "/srv/tftp";
      description = "atftpd: Document root directory";
    };
  };
  config = mkIf (cfg.tftpd.enable) {
    services.atftpd = {
      enable = true;
      root = cfg.tftpd.root;
    };
    networking.firewall.allowedUDPPorts = mkIf (cfg.tftpd.openFirewall) [ 69 ];
  };
}
