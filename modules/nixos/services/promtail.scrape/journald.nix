{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
  scrape = config.modules.tailScrapes;
in
{
  options.modules.tailScrapes.journald = {
    enable = mkOption {
      type = types.bool;
      default = elem "journald" cfg.promtail.scrapes;
    };
  };

  config = mkIf (cfg.promtail.enable && scrape.journald.enable) {
    services.promtail.configuration.scrape_configs = [
      {
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = "${toString config.modules.hostName}";
          };
        };
        relabel_configs = [
          {
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }
        ];
      }
    ];
  };
}
