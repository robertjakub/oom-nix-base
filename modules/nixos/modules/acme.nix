{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.modules.defaults.acme;
in
{
  options.modules.defaults.acme = {
    enable = mkEnableOption "defaults: acme";
    email = mkOption {
      type = types.str;
      default = "acme+ca@trustno1.corp";
    };
    server = mkOption {
      type = types.str;
      default = "https://ca.trustno1.corp:8443/acme/acme/directory";
    };
  };
  config = mkIf (cfg.enable) {
    security.acme = {
      acceptTerms = true;
      defaults.email = cfg.email;
      defaults.server = cfg.server;
      #defaults.server = "https://acme-v02.api.letsencrypt.org/directory";
    };
  };
}
