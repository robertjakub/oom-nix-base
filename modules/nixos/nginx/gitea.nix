{ config
, lib
, ...
}:
{
  vHost =
    if config.services.gitea.enable
    then {
      # addSSL = true;
      # enableACME = true;
      root = "${config.services.gitea.stateDir}/public";
      extraConfig = ''
        location / {
          try_files maintain.html $uri $uri/index.html @node;
        }
        location @node {
          client_max_body_size 0;
          proxy_pass http://${config.services.gitea.settings.server.HTTP_ADDR}:${toString config.services.gitea.settings.server.HTTP_PORT};
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Ssl on;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_max_temp_file_size 0;
          proxy_redirect off;
          proxy_read_timeout 120;
        }
      '';
    }
    else { };
}.vHost
