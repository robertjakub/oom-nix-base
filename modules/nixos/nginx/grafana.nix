{ config
, lib
, ...
}:
{
  vHost =
    if config.services.grafana.enable
    then {
      # addSSL = true;
      # enableACME = true;
      extraConfig = ''
        location / {
          proxy_pass http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port};
          proxy_set_header Host $host;
          proxy_set_header REMOTE_ADDR $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      '';
      #      extraConfig = ''
      #          client_max_body_size 0;
      #          proxy_max_temp_file_size 0;
      #          proxy_redirect off;
      #          proxy_read_timeout 120;
      #        }
      #      '';
    }
    else { };
}.vHost
