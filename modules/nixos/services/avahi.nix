{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem mkDefault;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
in
{
  options.modules.services.avahi = {
    enable = mkOption {
      type = types.bool;
      default = elem "avahi" cfg.services;
      description = "enable avahi";
    };
  };

  config = mkIf (cfg.avahi.enable) {
    services.avahi = {
      enable = true;
      nssmdns4 = mkDefault true;
      openFirewall = mkDefault true;
      publish = {
        enable = mkDefault true;
        # userServices = true;
        addresses = mkDefault true;
      };
    };
  };
}
