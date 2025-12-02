{ config
, lib
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.fs;
in
{
  options.modules.fs.fs.btrfs.enable = mkEnableOption "default filesystems";
  config = mkIf (cfg.fs.btrfs.enable && cfg.enable) {
    modules.fs = {
      defaults.fsType = "btrfs";
      fileSystems = [
        {
          path = "/";
          subvol = "@root";
          opts = [ "compress-force=zstd" ];
          neededForBoot = true;
        }
        {
          path = "/home";
          subvol = "@home";
          opts = [ "compress-force=zstd" ];
        }
        {
          path = "/nix";
          subvol = "@nix";
          opts = [ "compress-force=zstd" ];
          neededForBoot = true;
        }
        {
          path = "/persist";
          subvol = "@persist";
          opts = [ "compress-force=zstd" ];
          neededForBoot = true;
        }
        {
          path = "/var/log";
          subvol = "@log";
          opts = [ "compress-force=zstd" ];
          neededForBoot = true;
        }
      ];
    };
  };
}
