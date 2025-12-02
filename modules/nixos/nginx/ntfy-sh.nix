{ config
, lib
, ...
}:
with lib;
{
  vHost =
    if config.services.ntfy-sh.enable
    then {
      # addSSL = true;
      # enableACME = true;
      #sslCertificate = "/etc/nixos/secure/ntfy-sh.crt";
      #sslCertificateKey = "/etc/nixos/secure/ntfy-sh.key";
      root = "/persist/web/ntfy/";
      extraConfig = ''
        error_page 404 /404.html;
        location / {
          proxy_pass http://${config.services.ntfy-sh.settings.listen-http};
          proxy_set_header Host $host;
          proxy_set_header REMOTE_ADDR $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Real-IP $remote_addr;
          #proxy_http_version 1.1;
          #proxy_set_header Upgrade $http_upgrade;
          #proxy_set_header Connection "upgrade";

          proxy_intercept_errors on;
          error_page 404 = @fallback;
        }
        location @fallback {
          try_files 404.html $uri $uri/index.html =404;
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
