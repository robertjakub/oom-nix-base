{ config
, lib
, ...
}:
let
  inherit (lib) mkIf mkOption types;
  inSystem = config.boot.supportedFilesystems.btrfs or false;
  fsEnable = config.modules.fs.enable;
  cfg = config.modules.fs.btrfs;
  toolsEnable = inSystem && fsEnable && cfg.enable;
in
{
  options.modules.fs.btrfs.scrub = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    interval = mkOption {
      default = "weekly";
      type = types.str;
      example = "monthly";
      description = ''
        Systemd calendar expression for when to scrub btrfs filesystems.
      '';
    };
  };
  config = mkIf (toolsEnable && cfg.scrub.enable) {
    assertions = [
      {
        assertion = cfg.scrub.enable -> (cfg.fileSystems != [ ]);
        message = ''
          If 'modules.fs.btrfs.scrub' is enabled, you need to specify
          a list manually in 'modules.fs.btrfs.fileSystems'.
        '';
      }
    ];
    services.btrfs.autoScrub = {
      enable = true;
      interval = cfg.scrub.interval;
      fileSystems = cfg.fileSystems;
    };
  };
}
