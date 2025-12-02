{ ... }: {
  # services.prometheus.scrapeConfigs = [
  #   (lib.mkIf config.services.prometheus.enable {
  #     job_name = "uptime-kuma";
  #     scrape_interval = "30s";
  #     scrape_timeout = "5s";
  #     scheme = "http";
  #     metrics_path = "/metrics";
  #     static_configs = [{
  #       targets = [ "${config.services.uptime-kuma.settings.HOST}:${toString config.services.uptime-kuma.settings.PORT}" ];
  #     }];
  #     basic_auth = {
  #       username = "admin";
  #       password_file = config.sops.secrets."scrape/uptime-kuma".path;
  #     };
  #   })
  # ];

  # sops.secrets."scrape/uptime-kuma" = mkIf (defSops)
  #   (optionals config.services.prometheus.enable { owner = "prometheus"; group = "prometheus"; });
}
