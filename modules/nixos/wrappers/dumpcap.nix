{ config, lib, ... }: {
  config.modules.wrappers.sets.dumpcap.options = {
    owner = "root";
    group = "wireshark";
    permissions = lib.mkForce "u+xs,g+x";
    source = lib.mkForce "${config.programs.wireshark.package}/bin/dumpcap";
  };
}
