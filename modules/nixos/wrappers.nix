{ config, lib, pkgs, ... }:
let
  cfg = config.modules.wrappers;
  fn = import ../lib/internal.nix { inherit lib; };

  wrappersList = fn.makeOptionTypeList (toString ./wrappers);

  wrapperOption = pname: {
    name = pname;
    value = {
      wrap = lib.mkOption {
        type = with lib.types; attrs;
        default = cfg.sets."${pname}".options;
      };
      options = lib.mkOption {
        type = lib.types.unspecified;
        default = [ ];
      };
    };
  };
in
{
  options.modules.wrappers = {
    wrappers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum wrappersList);
      default = [ ];
    };
    sets = lib.listToAttrs (map wrapperOption (lib.lists.filter (v: !(lib.strings.hasInfix "::" v)) wrappersList));
  };

  imports = (fn.scanPaths ./wrappers);

  config = {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "wrappers: linux-only stanza!";
      }
    ];

    security.wrappers = lib.listToAttrs (lib.forEach cfg.wrappers (v: {
      name = v;
      value = cfg.sets.${v}.options;
    }));
  };
}
