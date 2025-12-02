{ config, lib, ... }:
let
  fn = import ./lib/internal.nix { inherit lib; };
  cfg = config.modules;
in
{
  imports = [ ./base.nix ] ++ (fn.scanPaths ./nixos);

  options.modules.defaults = {
    vmguest = lib.mkEnableOption { };
  };

  config = {
    documentation.dev.enable = lib.mkDefault true;
    documentation.nixos.enable = lib.mkDefault false;
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    services.journald.extraConfig = ''Compress=yes'';
    boot.tmp.cleanOnBoot = lib.mkDefault true;
    system.copySystemConfiguration = lib.mkDefault false;

    powerManagement = {
      enable = if config.boot.isContainer then false else lib.mkDefault true;
      cpuFreqGovernor = lib.mkDefault "ondemand";
    };
    virtualisation.vmware.guest.enable = cfg.defaults.vmguest;

    nix.optimise.automatic = if config.boot.isContainer then lib.mkDefault false else lib.mkDefault true;
    system.stateVersion = "25.11";
  };
}
