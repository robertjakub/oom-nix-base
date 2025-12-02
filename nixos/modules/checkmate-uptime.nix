{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types;
  inherit (lib) isPath;
  inherit (builtins) toString;
  cfg = config.services.additions.checkmate;

  assertStringPath = optionName: value:
    if isPath value
    then
      throw ''
        services.additions.checkmate-capture.${optionName}:
          ${toString value}
          is a Nix path, but should be a string, since Nix
          paths are copied into the world-readable Nix store.
      ''
    else value;
in
{
  options.services.additions.checkmate = {
    enable = mkEnableOption "Checkmate";
    package = mkPackageOption pkgs.oom-base "checkmate" { };

    nginx = mkOption {
      type = types.bool;
      default = true;
      description = "Enable NGINX reverse proxy.";
    };

    redis = mkOption {
      type = types.bool;
      default = true;
      description = "Enable REDIS.";
    };

    settings.clientHost = mkOption {
      type = types.str;
      default = "http://127.0.0.1";
      description = "Frontend Host";
    };

    settings.loginURL = mkOption {
      type = types.str;
      default = "http://127.0.0.1";
      description = "Login url to be used in emailing service";
    };

    settings.JWTSecretFile = mkOption {
      type = types.path;
      apply = assertStringPath "JWTSecretFile";
      description = "The JWT secret key (file).";
    };

    mongodbUri = mkOption {
      type = types.str;
      default = "mongodb://127.0.0.1:27017/uptime_db";
    };
  };
  config = mkIf cfg.enable {
    services.redis.servers.checkmate = mkIf cfg.redis {
      enable = true;
      port = 6379;
    };

    services.nginx = mkIf cfg.nginx {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts.default = {
        locations."/" = {
          root = "${cfg.package}/client";
          index = "index.html index.htm";
          tryFiles = "$uri $uri/ /index.html";
        };
        locations."/api/" = {
          proxyPass = "http://127.0.0.1:52345/api/";
          proxyWebsockets = true;
        };
        locations."/api-docs/" = {
          proxyPass = "http://127.0.0.1:52345/api-docs/";
          proxyWebsockets = true;
        };
      };
    };

    systemd.services.checkmate-backend = {
      description = "Checkmate backend daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      startLimitIntervalSec = 60;
      startLimitBurst = 3;
      environment = {
        CLIENT_HOST = cfg.settings.clientHost;
        REFRESH_TOKEN_SECRET = "1h";
        LOGIN_PAGE_URL = cfg.settings.loginURL;
        REDIS_HOST = "127.0.0.1";
        REDIS_PORT = "6379";
        DB_CONNECTION_STRING = cfg.mongodbUri;
      };
      serviceConfig = {
        LoadCredential = [ "JWT_SECRET:${cfg.settings.JWTSecretFile}" ];
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = "read-only";
        NoNewPrivileges = true;
        LimitCORE = 0;
        KillSignal = "SIGINT";
        TimeoutStopSec = "30s";
        Restart = "on-failure";
        DynamicUser = true;
      };
      script = ''
        set -eou pipefail
        shopt -s inherit_errexit

        JWT_SECRET="$(<"$CREDENTIALS_DIRECTORY/JWT_SECRET")" \
        ${cfg.package}/startserver ${cfg.package}/server/src/index.js
      '';
    };

    # END of File
  };
}
