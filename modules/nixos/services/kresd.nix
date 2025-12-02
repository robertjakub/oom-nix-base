{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf elem mkDefault mkEnableOption;
  cfg = config.modules.services;
in
{
  options.modules.services.kresd.openFirewall = mkEnableOption "kresd: open default ports";
  config = mkIf (elem "kresd" cfg.services) {
    services.kresd = {
      enable = true;
      instances = mkDefault 1;
      listenPlain = [ ];
      # listenPlain = mkDefault ["127.0.0.1:53"];
      package = pkgs.knot-resolver.override { extraFeatures = true; };
    };
    networking.firewall = mkIf (cfg.kresd.openFirewall) {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}
