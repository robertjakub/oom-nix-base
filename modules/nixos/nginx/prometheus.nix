{ config, ... }:
let
  inherit (builtins) toString;
  cfg = config.services.prometheus;
in
{
  vHost =
    if cfg.enable
    then {
      extraConfig = ''
        location / {
          proxy_pass http://${toString cfg.listenAddress}:${toString cfg.port};
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
    }
    else { };
}.vHost
