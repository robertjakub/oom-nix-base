{ config
, lib
, ...
}:
let
  inherit (lib) mkIf;
  inherit (builtins) toString;
  cfg = config.modules.services.gitea;
in
{
  vHost = mkIf (cfg.enable) {
    root = "${cfg.stateDir}/public";
    locations."/".tryFiles = "maintain.html $uri $uri/index.html @node";
    locations."@node".proxyWebsockets = true;
    locations."@node".proxyPass = "http://${cfg.http_addr}:${toString cfg.http_port}";
    locations."@node".extraConfig = ''
      client_max_body_size 0;
      proxy_set_header X-Forwarded-Ssl on;
      proxy_max_temp_file_size 0;
      proxy_redirect off;
      proxy_read_timeout 120;
    '';
  };
}.vHost
