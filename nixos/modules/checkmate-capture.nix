{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types;
  inherit (lib) isPath;
  inherit (builtins) toString;
  cfg = config.services.additions.checkmate-capture;

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
  options.services.additions.checkmate-capture = {
    enable = mkEnableOption "Checkmate capture agent";
    package = mkPackageOption pkgs.oom-base "checkmate-capture" { };

    ginMode = mkOption {
      type = types.enum [ "release" "debug" ];
      default = "release";
      description = "The mode of the Gin framework";
    };

    port = mkOption {
      type = types.int;
      default = 59232;
      description = "The port that the Capture listens on";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the firewall port(s).";
    };

    apiSecretFile = mkOption {
      type = types.path;
      apply = assertStringPath "apiSecretFile";
      description = "The secret key (file) for the API";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.checkmate-agent = {
      description = "Checkmate capture agent.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      startLimitIntervalSec = 60;
      startLimitBurst = 3;
      environment = {
        GIN_MODE = cfg.ginMode;
        PORT = toString cfg.port;
      };
      serviceConfig = {
        LoadCredential = [ "API_SECRET:${cfg.apiSecretFile}" ];
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

        API_SECRET="$(<"$CREDENTIALS_DIRECTORY/API_SECRET")" ${cfg.package}/bin/capture
      '';
    };
  };
}
