{ config
, lib
, ...
}:
with lib; let
  cfg = config.services.passcore;
in
{
  vHost =
    if cfg.enable
    then {
      extraConfig = ''
        location / {
          proxy_pass http://127.0.0.1:${toString cfg.port};
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
