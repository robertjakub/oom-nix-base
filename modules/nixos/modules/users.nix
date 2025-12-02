{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf listToAttrs optional optionals;
  inherit (builtins) elem;

  cfg = config.modules.users;

  users = user: {
    inherit (user) name;
    value =
      let
        passPath = config.sops.secrets."users/${user.name}/password".path or null;
        isAdmin = elem "admin" user.tags;
        isTape = elem "tape" user.tags;
      in
      {
        inherit (user) name;
        isNormalUser = true;
        uid = user.id;
        # group = user.name; # use default
        createHome = user.createHome;
        group = mkIf (user.group != null) user.group;
        shell =
          if user.shell != null
          then user.shell
          else "${pkgs.zsh}/bin/zsh"; # default shell: ZSH
        extraGroups =
          [ ]
          # ++ ["audio" "network"]
          ++ (optionals config.services.xserver.enable [ "input" "video" ])
          ++ (optional (isTape && config.modules.defaults.tape.enable) "tape")
          ++ (optional (isAdmin && config.networking.networkmanager.enable) "networkmanager")
          ++ (optionals (isAdmin && config.services.printing.enable) [ "cups" "lp" ])
          ++ (optional (isAdmin && config.programs.wireshark.enable) "wireshark")
          ++ (optional (isAdmin && config.virtualisation.docker.enable) "docker")
          ++ (optional (isAdmin && config.hardware.i2c.enable) "i2c")
          ++ (optional isAdmin "wheel");
        hashedPasswordFile = passPath;
      };
  };
in
{
  config = mkIf cfg.enable {
    users = {
      users = listToAttrs (map users cfg.users);
      mutableUsers = cfg.mutableUsers;
    };
  };
}
