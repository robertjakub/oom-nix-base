{ config, pkgs, ... }: {
  config.modules.wrappers.sets.fping.options = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_raw+ep";
    source = "${pkgs.fping}/bin/fping";
  };
}
