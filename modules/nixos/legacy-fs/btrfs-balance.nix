{ config
, lib
, utils
, pkgs
, ...
}:
let
  inherit (lib) mkOption types;
  inherit (lib) mkIf optionals;
  inherit (lib) nameValuePair listToAttrs;
  inSystem = config.boot.supportedFilesystems.btrfs or false;
  fsEnable = config.modules.fs.enable;
  cfg = config.modules.fs.btrfs;
  toolsEnable = inSystem && fsEnable && cfg.enable;
  scrubEnable = cfg.scrub.enable;
in
{
  options.modules.fs.btrfs.balance = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    interval = mkOption {
      default = "monthly";
      type = types.str;
      example = "weekly";
      description = ''
        Systemd calendar expression for when to balance btrfs filesystems.
      '';
    };
    dusage = mkOption {
      default = 10;
      type = types.int;
    };
    musage = mkOption {
      default = 10;
      type = types.int;
    };
  };
  config = mkIf (toolsEnable && cfg.balance.enable) {
    assertions = [
      {
        assertion = cfg.balance.enable -> (cfg.fileSystems != [ ]);
        message = ''
          If 'modules.fs.btrfs.balance' is enabled, you need to specify
          a list manually in 'modules.fs.btrfs.fileSystems'.
        '';
      }
    ];
    systemd.timers =
      let
        balanceTimer = fs:
          let
            fs' = utils.escapeSystemdPath fs;
          in
          nameValuePair "btrfs-balance-${fs'}" {
            description = "regular btrfs balance timer on ${fs}";

            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = cfg.balance.interval;
              AccuracySec = "1d";
              Persistent = true;
            };
          };
      in
      listToAttrs (map balanceTimer cfg.fileSystems);

    systemd.services =
      let
        balanceService = fs:
          let
            fs' = utils.escapeSystemdPath fs;
          in
          nameValuePair "btrfs-balance-${fs'}" {
            description = "btrfs balance on ${fs}";
            conflicts = [ "shutdown.target" "sleep.target" ];
            before = [ "shutdown.target" "sleep.target" ];
            after = optionals scrubEnable [ "btrfs-scrub-${fs'}.service" ];
            serviceConfig = {
              # simple and not oneshot, otherwise ExecStop is not used
              Type = "simple";
              Nice = 19;
              IOSchedulingClass = "idle";
              # if the service is stopped before balance end, cancel it
              ExecStop = pkgs.writeShellScript "btrfs-balance-maybe-cancel" ''
                (${pkgs.btrfs-progs}/bin/btrfs balance status ${fs} | ${pkgs.gnugrep}/bin/grep "No balance found") || ${pkgs.btrfs-progs}/bin/btrfs balance cancel ${fs}
                ${pkgs.coreutils}/bin/sleep 2
                (${pkgs.btrfs-progs}/bin/btrfs balance status ${fs} | ${pkgs.gnugrep}/bin/grep "No balance found") || ${pkgs.btrfs-progs}/bin/btrfs balance cancel ${fs}
              '';
            };
            script = ''
              set -o errexit -o pipefail -o nounset -o errtrace
              shopt -s inherit_errexit
              ${pkgs.btrfs-progs}/bin/btrfs -q balance start -musage=0 -dusage=0 ${fs}
              ${pkgs.btrfs-progs}/bin/btrfs -q balance start -musage=${toString cfg.balance.musage} -dusage=${toString cfg.balance.dusage} ${fs}
            '';
          };
      in
      listToAttrs (map balanceService cfg.fileSystems);
  };
}
