{ config
, lib
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types listToAttrs;
  cfg = config.modules.fs;
  fn = import ../../lib/internal.nix { inherit lib; };

  fsOpts = { ... }: {
    options = {
      path = mkOption { type = types.str; };
      fsType = mkOption {
        type = types.str;
        default = cfg.defaults.fsType;
      };
      uuid = mkOption {
        type = types.str;
        default = cfg.defaults.uuid;
      };
      opts = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      subvol = mkOption {
        type = types.str;
      };
      neededForBoot = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  fsMap = fs: {
    name = fs.path;
    value =
      let
        device = "/dev/disk/by-uuid/${fs.uuid}";
        subvol =
          if (fs.fsType == "btrfs")
          then [ "subvol=${fs.subvol}" ]
          else [ ];
        opts = (cfg.defaults.opts.${fs.fsType} or [ ]) ++ fs.opts ++ subvol;
      in
      {
        inherit (fs) fsType neededForBoot;
        inherit device;
        options = mkIf (opts != [ ]) opts;
      };
  };
in
{
  options.modules.fs = {
    enable = mkEnableOption "default filesystems";
    defaults.uuid = mkOption {
      type = types.str;
      default = "";
    };
    defaults.fsType = mkOption {
      type = types.str;
      default = "ext4";
    };
    defaults.opts = mkOption {
      type = with types; attrsOf (listOf str);
      default = {
        "ext4" = [ ];
        "vfat" = [ "fmask=0022" "dmask=0022" ];
        "btrfs" = [ "noatime" "ssd_spread" "autodefrag" "discard=async" ];
      };
    };
    fileSystems = mkOption {
      type = types.listOf (types.submodule [ fsOpts ]);
      default = [ ];
    };
    btrfs.enable = mkEnableOption "enable btrfs tools";
    btrfs.fileSystems = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = [ "/" ];
      description = ''
        List of paths to btrfs filesystems to regularly call some btrfs commands on.
      '';
    };
  };
  config = mkIf (cfg.enable) {
    fileSystems = listToAttrs (map fsMap cfg.fileSystems);
  };
  imports = fn.scanPaths ./.;
}
