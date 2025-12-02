{ config, lib, pkgs, ... }:
let cfg = config.modules.defaults.sys-pkgs;
in
{
  options.modules.defaults = {
    sys-pkgs.enable = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."current-system-packages".text =
      let
        packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
        sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
      formatted;
  };
}
