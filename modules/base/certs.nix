{ lib, config, ... }:
let
  fn = import ../lib/internal.nix { inherit lib; };
  certDir = "${config.modules.defaults.configRoot}/defaults/certs";
  certList = fn.makeOptionSuffixList { p = certDir; s = ".pem"; };
  cfg = config.modules.cacerts;
in
{
  options.modules.cacerts = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    certs = lib.mkOption { type = lib.types.listOf (lib.types.enum certList); default = certList; };
  };

  config = lib.mkIf cfg.enable {
    security.pki.certificateFiles = [ ] ++ (lib.forEach cfg.certs (x: /. + (certDir + "/" + toString x + ".pem")));
  };
}
