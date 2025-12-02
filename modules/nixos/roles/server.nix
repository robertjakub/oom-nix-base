{ lib, config, ... }:
let defaults = config.modules.defaults;
in {
  config = lib.mkIf (lib.elem "server" defaults.roles) {
    modules.wrappers.wrappers = [ "fping" ];
    modules.apps.apps = [ "mtr" "wireshark" ];
    modules.services.services = [ "avahi" ]; # FIXME

    systemd.network.enable = true;

    systemd.network.networks."80-container-ve" = {
      matchConfig = { Name = "ve-*"; Kind = "veth"; };
      linkConfig.Unmanaged = true;
    };
    networking.useDHCP = false;
    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      enableIPv6 = false;
    };
  };

}
