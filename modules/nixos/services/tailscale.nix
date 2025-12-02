{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem types mkOption;
  cfg = config.modules.services;
in
{
  options.modules.services.tailscale = {
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "tailscale: open default ports";
    };
    nat = mkOption {
      type = types.bool;
      default = true;
      description = "tailscale: make default nat rules";
    };
  };

  config = mkIf (elem "tailscale" cfg.services) {
    services.tailscale.enable = true;
    services.tailscale.useRoutingFeatures = "both";

    networking.firewall = mkIf (cfg.tailscale.openFirewall) {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
    networking.nat = mkIf (cfg.tailscale.nat) {
      enable = true;
      internalInterfaces = [ "tailscale0" ];
      externalInterface = config.modules.defaultIF;
    };
  };
}
