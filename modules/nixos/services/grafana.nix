{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem findFirst;
  inherit (lib) mkOption types;
  inherit ((findFirst (s: s.service == "grafana") config.modules config.modules.nginx.vHosts)) domain;
  cfg = config.modules.services;
  defSops = config.modules.defaults.sops.enable;

  dsOpts = { config, ... }: {
    options = {
      name = mkOption { type = types.str; };
      type = mkOption { type = types.str; };
      url = mkOption { type = types.str; };
      isDefault = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  mkDS = ds: {
    inherit (ds) name;
    inherit (ds) type url isDefault;
    access = "proxy";
  };
in
{
  options.modules.services.grafana = {
    enable = mkOption {
      type = types.bool;
      default = elem "grafana" cfg.services;
      description = "enable grafana";
    };
    http_addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "grafana: default addr";
    };
    http_port = mkOption {
      type = types.int;
      default = 9034;
      description = "grafana: default port";
    };
    domain = mkOption {
      type = types.str;
      default = domain;
    };
    database.local = mkOption {
      type = types.bool;
      default = false;
    };
    database.host = mkOption {
      type = types.str;
      default = "/run/postgresql";
    };
    database.port = mkOption {
      type = types.int;
      default = 5432;
    };
    datasources = mkOption {
      type = types.listOf (types.submodule [ dsOpts ]);
      default = [ ];
    };
  };

  config = mkIf (cfg.grafana.enable) {
    services.grafana = {
      enable = true;
      settings = {
        analytics.reporting_enabled = false;
        "auth.anonymous".enabled = false;
        users.allowSignUp = false;
        server = {
          domain = cfg.grafana.domain;
          http_addr = cfg.grafana.http_addr;
          http_port = cfg.grafana.http_port;
          protocol = "http";
          root_url = "https://${cfg.grafana.domain}/";
        };
        database = {
          type = "postgres";
          host = cfg.grafana.database.host;
          port = cfg.grafana.database.port;
          user = "grafana";
          name = "grafana";
          password = "$__file{" + config.sops.secrets."services/grafana/dbPass".path + "}";
        };
        metrics = {
          enabled = true;
          disable_total_stats = true;
        };
      };

      provision = {
        enable = true;
        datasources.settings.datasources = map mkDS cfg.grafana.datasources;
      };
    };

    # services.postgresql.ensureDatabases = ["grafana"];
    # services.postgresql.ensureUsers = [{ name = "grafana"; ensureDBOwnership = true; }];

    sops.secrets."services/grafana/dbPass" = mkIf defSops {
      owner = "grafana";
      group = "grafana";
    };
  };
}
