{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.services.dnscollector;
  yaml-format = pkgs.formats.yaml { };
  settings-yaml = yaml-format.generate "dnscollector.yaml" cfg.settings;
in
{
  options.services.dnscollector = {
    enable = mkEnableOption "A passive high speed ingestor with pipelining support for your DNS logs.";
    package = mkOption {
      type = types.package;
      default = pkgs.go-dnscollector;
    };
    settings = mkOption {
      type = yaml-format.type;
      default = { };
    };
    settingsFile = mkOption {
      type = with types; nullOr path;
      default = null;
      description = "A replacement for the generated config.yml file.";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."dnscollector/dnscollector.yaml" = {
      user = "dnscollector";
      group = "dnscollector";
      source = cfg.settingsFile or settings-yaml;
    };

    systemd.services."dnscollector" = {
      wantedBy = [ "multi-user.target" ];
      unitConfig = { ConditionFileNotEmpty = "/etc/dnscollector/dnscollector.yaml"; };
      serviceConfig = {
        User = "dnscollector";
        Group = "dnscollector";
        UMask = "0007";
        ExecStart = "${cfg.package}/bin/go-dnscollector -config /etc/dnscollector/dnscollector.yaml";
        ExecReload = [
          "${cfg.package}/bin/go-dnscollector -test-config"
        ];
        RuntimeDirectory = "dnscollector";
        DynamicUser = true;
        StateDirectory = "dnscollector";
        # AmbientCapabilities=CAP_NET_BIND_SERVICE;
        # CapabilityBoundingSet=CAP_NET_BIND_SERVICE;
        # LimitNOFILE=20500;
        # MemoryDenyWriteExecute=true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    users.users.dnscollector = {
      home = "/var/lib/dnscollector";
      group = "dnscollector";
      isSystemUser = true;
    };
    users.groups.dnscollector = { };
  };
}
