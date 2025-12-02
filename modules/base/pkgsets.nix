{ lib, config, ... }:
let
  fn = import ../lib/internal.nix { inherit lib; };

  pkgsets = fn.lst { p = toString ((fn.relativeToRoot) "./pkgsets"); b = true; };
  pkgsetList = fn.makeOptionTypeList (toString ((fn.relativeToRoot) "./pkgsets"));

  pkgOption = pname: {
    name = pname;
    value = {
      pkgwrap = lib.mkOption {
        type = with lib.types; oneOf [ package (listOf package) ];
        default = fn.pkgFilter cfg.pkgsets."${pname}".pkgs;
        description = ''
          Package Wrapper for packages using a wrapper function (like python, emacs, haskell, ...)
        '';
      };
      pkgs = lib.mkOption {
        type = lib.types.unspecified;
        default = [ ];
        description = ''
          ${pname} package list.
        '';
      };
    };
  };
  cfg = config.modules.pkgsets;
in
{
  options.modules.pkgsets = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    pkgs = lib.mkOption {
      type = lib.types.listOf (lib.types.enum pkgsetList);
      default = [ "base-small" ];
      description = "The list of metapackages to be installed.";
    };
    pkgsets = lib.listToAttrs (
      map pkgOption (lib.lists.filter (v: !(lib.strings.hasInfix "::" v)) pkgsetList)
    );
  };
  imports = pkgsets;
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.flatten (lib.forEach
      (lib.attrVals (lib.lists.filter (v: !(lib.strings.hasInfix "::" v)) cfg.pkgs) cfg.pkgsets)
      (v: v.pkgwrap)
    );
  };
}
