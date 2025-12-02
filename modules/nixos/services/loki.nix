{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf elem mkDefault;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
  # stablepkgs = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/04220ed6763637e5899980f98d5c8424b1079353.tar.gz";
  #   sha256 = "sha256:1n3yqvj1kfqw8pscsw1k1zfqlsxyn6b201w60msvwjsp9lxqgj4q";
  # }) {};
in
{
  options.modules.services.loki = {
    enable = mkOption {
      type = types.bool;
      default = elem "loki" cfg.services;
      description = "enable loki";
    };
    # http_addr = mkOption { type = types.str; default = "127.0.0.1"; description = "loki: default addr"; };
    http_port = mkOption {
      type = types.int;
      default = 9030;
      description = "loki: default port";
    };
  };

  config = mkIf (cfg.loki.enable) {
    services.loki = {
      enable = true;
      package = pkgs.grafana-loki;
      configFile = mkDefault configs/loki.default.json;
      extraFlags = [
        "--server.http-listen-port=${toString cfg.loki.http_port}"
      ];
    };
  };
}
