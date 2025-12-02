{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.homer;

  yaml-format = pkgs.formats.yaml { };
  settings-yaml = yaml-format.generate "homer-config.yml" cfg.settings;

  settings-path =
    if cfg.settings-path != null
    then cfg.settings-path
    else builtins.toString settings-yaml;
in
{
  vHost =
    if cfg.enable
    then {
      locations."/" = {
        root = pkgs.homer;
      };
      locations."= /assets/config.yml" = {
        alias = settings-path;
      };
    }
    else { };
}.vHost
