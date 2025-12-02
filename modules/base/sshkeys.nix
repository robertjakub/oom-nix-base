{ lib, config, ... }:
let
  fn = import ../lib/internal.nix { inherit lib; };
  cfgRootDir = config.modules.defaults.configRoot;
  sshDir = "${cfgRootDir}/defaults/sshkeys";

  sshkeysList = fn.makeOptionSuffixList { p = sshDir; s = ".pub"; };
  sshKeys = lib.listToAttrs (map
    (name: {
      name = name;
      value = lib.removeSuffix "\n" (builtins.readFile (toString (/. + "${sshDir}/${name}.pub")));
    })
    sshkeysList);
in
{
  options.modules.sshkeys.sshKeys = lib.mkOption { type = lib.types.attrs; default = sshKeys; };

}
