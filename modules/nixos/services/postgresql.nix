{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types mkPackageOption;
  cfg = config.modules.services;
in
{
  options.modules.services.postgresql = {
    enable = mkOption {
      type = types.bool;
      default = elem "postgresql" cfg.services;
    };
    tcpip = mkOption {
      type = types.bool;
      default = true;
    };
    package = mkPackageOption pkgs "postgresql_14" { };
    # http_addr = mkOption { type = types.str; default = "127.0.0.1"; description = "psql14: default addr"; };
    # http_port = mkOption { type = types.int; default = 9036; description = "psql14: default port"; };
  };
  config = mkIf (cfg.postgresql.enable) {
    services.postgresql = {
      enable = true;
      enableTCPIP = cfg.postgresql.tcpip;
      package = cfg.postgresql.package;
    };
  };
}
