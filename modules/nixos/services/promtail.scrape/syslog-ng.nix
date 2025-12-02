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
  options.modules.tailScrapes.syslog-ng = {
    enable = mkOption {
      type = types.bool;
      default = elem "syslog-ng" cfg.promtail.scrapes;
    };
    http_addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "promtail/syslog: default addr";
    };
    http_port = mkOption {
      type = types.int;
      default = 1514;
      description = "promtail/syslog: default port";
    };
  };

  config = mkIf (cfg.promtail.enable && scrape.syslog-ng.enable) {
    services.promtail.configuration.scrape_configs = [
      {
        job_name = "syslog";
        syslog = {
          listen_address = "${scrape.syslog-ng.http_addr}:${toString scrape.syslog-ng.http_port}";
          idle_timeout = "180s";
          max_message_length = 65536;
          label_structured_data = true;
          labels = {
            job = "syslog";
          };
        };
        pipeline_stages = [
          {
            json.expressions = {
              host = "HOST";
              priority = "PRIORITY";
              severity = "severity";
              message = "MESSAGE";
              timestamp = "ISODATE";
              facility = "FACILITY";
            };
          }
          {
            timestamp = {
              format = "RFC3339";
              source = "timestamp";
            };
          }
          {
            labels = {
              severity = null;
              host = null;
              priority = null;
              facility = null;
              # HOST_FROM = null;
            };
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__syslog_message_severity" ];
            target_label = "level";
          }
          # { source_labels = [ "__syslog_message_hostname" ]; target_label = "host"; }
          # { source_labels = [ "__syslog_message_facility" ]; target_label = "facility"; }
          # { source_labels = [ "__syslog_message_app_name" ]; target_label = "application"; }
          # { source_labels = [ "__syslog_connection_hostname" ]; target_label = "connection_hostname"; }
        ];
      }
    ];
  };
}
