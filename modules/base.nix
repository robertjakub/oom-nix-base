{ lib, config, ... }:
let
  cfg = config.modules;
  fn = import ./lib/internal.nix { inherit lib; };
in
{
  imports = [ ./shell/all-shells.nix ] ++ (fn.scanPaths ./base);

  options.modules = {
    hostName = lib.mkOption { type = lib.types.str; };
    domain = lib.mkOption { type = lib.types.str; default = "local"; };
    etchost = lib.mkOption { type = lib.types.str; default = config.modules.hostName; };
  };
  options.modules.defaults = {
    configRoot = lib.mkOption { type = lib.types.path; };
    timeZone = lib.mkOption { type = lib.types.str; default = "Europe/Warsaw"; };
    allowUnfree = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = {

    nix.settings.download-buffer-size = lib.mkDefault 134217728;
    environment.etc."rebuildhost".text = ''${config.modules.etchost}'';

    time.timeZone = cfg.defaults.timeZone;
    documentation.man.enable = lib.mkDefault 1000 true;
    networking.hostName = cfg.hostName;
    nixpkgs.config.allowUnfree = cfg.defaults.allowUnfree;
    nixpkgs.flake.setNixPath = lib.mkDefault false;
    nixpkgs.flake.setFlakeRegistry = lib.mkDefault false;
    nix.settings = {
      connect-timeout = lib.mkDefault 5;
      max-jobs = lib.mkDefault 4;
      cores = lib.mkDefault 0;
      sandbox = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" ];
      require-sigs = lib.mkDefault false;
      trusted-users = [ "toor" "oom" ]; # FIXME should be moved to [system]-config
    };
  };
}
