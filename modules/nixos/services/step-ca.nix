{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
in
{
  options.modules.services.step-ca = {
    enable = mkOption {
      type = types.bool;
      default = elem "step-ca" cfg.services;
      description = "enable step-ca";
    };
    enabled = mkOption {
      type = types.bool;
      default = false;
      description = "step-ca: manual config";
    };
    http_addr = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "step-ca: default addr";
    };
    http_port = mkOption {
      type = types.int;
      default = 9032;
      description = "step-ca: default port";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "step-ca: open default ports";
    };
  };
  config = mkIf (cfg.step-ca.enable) {
    assertions = [
      {
        assertion = cfg.step-ca.enabled;
        message = "step-ca: manual configuration required";
      }
    ];

    #    environment.systemPackages = [pkgs.step-cli];
    services.step-ca = {
      enable = true;
      address = cfg.step-ca.http_addr;
      port = cfg.step-ca.http_port;
    };

    networking.firewall.allowedUDPPorts = mkIf (cfg.step-ca.openFirewall) [ config.services.step-ca.port ];
  };
}
