{ config
, lib
, ...
}:
{
  vHost = {
    locations."/".tryFiles = "maintain.html $uri $uri.html $uri/index.html =404";
    locations."/".index = "index.html";
    locations."/".extraConfig = ''
      error_page 404 /404.html;
      error_page 500 502 503 504 /50x.html;
    '';
    locations."/404.html".extraConfig = ''
      internal;
    '';
    locations."/50x.html".extraConfig = ''
      internal;
    '';
  };
}.vHost
# { config, lib, ... }:
# with lib;
# {
#   vHost =
#     if config.services.gitea.enable then {
#       # addSSL = true;
#       # enableACME = true;
#       root = "${config.services.gitea.stateDir}/public";
#       extraConfig = ''
#         location / {
#           try_files maintain.html $uri $uri/index.html @node;
#         }
#         location @node {
#           client_max_body_size 0;
#           proxy_pass http://${config.services.gitea.settings.server.HTTP_ADDR}:${toString config.services.gitea.settings.server.HTTP_PORT};
#           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#           proxy_set_header X-Real-IP $remote_addr;
#           proxy_set_header Host $host;
#           proxy_set_header X-Forwarded-Ssl on;
#           proxy_set_header X-Forwarded-Proto $scheme;
#           proxy_max_temp_file_size 0;
#           proxy_redirect off;
#           proxy_read_timeout 120;
#         }
#       '';
#     } else {};
# }.vHost
