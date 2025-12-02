{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf elem mkForce optional;
  inherit (lib) mkOption types;
  cfg = config.modules.services;

  kuma-paths = with pkgs;
    [ unixtools.ping ]
    ++ optional config.services.tailscale.enable pkgs.tailscale
    ++ optional config.services.uptime-kuma.appriseSupport apprise;
in
{
  options.modules.services.uptime-kuma = {
    enable = mkOption {
      type = types.bool;
      default = elem "uptime-kuma" cfg.services;
      description = "enable uptime-kuma";
    };
    http_addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "uptime-kuma: default addr";
    };
    http_port = mkOption {
      type = types.int;
      default = 9037;
      description = "uptime-kuma: default port";
    };
  };
  config = mkIf (cfg.uptime-kuma.enable) {
    systemd.services.uptime-kuma.path = mkForce kuma-paths;
    services.uptime-kuma = {
      enable = true;
      package = pkgs.uptime-kuma;
      settings.PORT = toString cfg.uptime-kuma.http_port;
    };
  };
}
