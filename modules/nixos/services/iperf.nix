{ lib
, config
, pkgs
, ...
}:
let
  inherit (lib) mkIf mkOption types elem;
  cfg = config.modules.services;
in
{
  options.modules.services.iperf = {
    enable = mkOption {
      type = types.bool;
      default = elem "iperf" cfg.services;
    };
    port = mkOption {
      type = types.ints.u16;
      default = 5201;
    };
    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.iperf.enable) {
    services.iperf3 = {
      enable = true;
      port = cfg.iperf.port;
      bind = cfg.iperf.bind;
      openFirewall = cfg.iperf.openFirewall;
      forceFlush = true;
    };

    environment.systemPackages = with pkgs; [ iperf3 ];
  };
}
