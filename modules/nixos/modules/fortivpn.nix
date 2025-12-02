{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types listToAttrs;
  cfg = config.modules.fortivpn;

  vpnOpts = { config, ... }: {
    options = {
      name = mkOption { type = types.str; };
      config = mkOption { type = types.str; };
    };
  };

  vpnSVC = vpn: {
    name = "openfortivpn@${vpn.name}";
    value = {
      description = "OpenFortiVPN (${vpn.name})";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "notify";
        PrivateTmp = true;
        Restart = "on-failure";
        OOMScoreAdjust = -100;
        ExecStart = ''${pkgs.openfortivpn}/bin/openfortivpn -c ${vpn.config}'';
      };
    };
  };
in
{
  options.modules.fortivpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    vpns = mkOption {
      type = types.listOf (types.submodule [ vpnOpts ]);
      default = { };
    };
  };
  config = mkIf (cfg.enable) {
    systemd.services = listToAttrs (map vpnSVC cfg.vpns);
  };
}
