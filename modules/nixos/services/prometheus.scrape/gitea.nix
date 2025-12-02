{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
  scrape = config.modules.scrapes;
in
{
  options.modules.scrapes.gitea = {
    enable = mkOption {
      type = types.bool;
      default = elem "gitea" cfg.prometheus.scrapes;
    };
    target = mkOption {
      type = types.str;
      default = "${cfg.gitea.http_addr}:${toString cfg.gitea.http_port}";
    };
  };

  config = mkIf (cfg.prometheus.enable && scrape.gitea.enable) {
    services.prometheus.scrapeConfigs = [
      {
        job_name = "gitea";
        scrape_interval = "15s";
        scrape_timeout = "5s";
        static_configs = [
          {
            targets = [ "${scrape.gitea.target}" ];
          }
        ];
      }
    ];
  };
}
