{ config, lib, pkgs, ... }:
let
  cfg = config.modules.users;

  userOpts = { ... }: {
    options = {
      name = lib.mkOption { type = lib.types.str; };
      description = lib.mkOption { type = with lib.types; nullOr str; default = null; };
      home = lib.mkOption { type = with lib.types; nullOr str; default = null; };
      sshkeys = lib.mkOption { type = with lib.types; listOf str; default = [ ]; };
      id = lib.mkOption { type = with lib.types; nullOr int; default = null; };
      tags = lib.mkOption { type = with lib.types; listOf str; default = [ ]; };
      shell = lib.mkOption { type = with lib.types; nullOr str; default = null; };
      createHome = lib.mkOption { type = with lib.types; bool; default = true; };
      group = lib.mkOption { type = with lib.types; nullOr str; default = null; };
    };
  };

  users = user: {
    inherit (user) name;
    value =
      let
        homePath =
          if pkgs.stdenv.isDarwin
          then "/Users"
          else "/home";
        home =
          if user.home != null
          then user.home
          else "${homePath}/${user.name}";
      in
      {
        inherit (user) name;
        description =
          if user.description != null
          then user.description
          else "Administrative user ${user.name}";
        home = builtins.toPath home;
        packages = lib.mkDefault [ ];
        openssh.authorizedKeys.keys = user.sshkeys;
      };
  };
in
{
  options.modules.users = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    mutableUsers = lib.mkOption { type = lib.types.bool; default = true; };
    users = lib.mkOption { type = lib.types.listOf (lib.types.submodule [ userOpts ]); default = [ ]; };
    rootkeys = lib.mkOption { type = with lib.types; listOf str; default = [ ]; };
  };
  config = lib.mkIf cfg.enable {
    users.users = lib.listToAttrs (map users cfg.users);
  };
}
