{ config, lib, ... }:
let cfg = config.modules.apps;
in lib.mkIf (lib.elem "vmware" cfg.apps) {
  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.host.extraConfig = ''
    mks.gl.allowUnsupportedDrivers = "TRUE"
    mks.vk.allowUnsupportedDevices = "TRUE"
  '';
}
