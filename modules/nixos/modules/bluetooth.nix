{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.modules.bluetooth;
in
{
  options.modules.bluetooth = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          ControllerMode = "dual";
          FastConnectable = "true";
          Experimental = "true";
        };
      };
    };
    services.blueman.enable = true;
  };
}
