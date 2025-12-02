{ lib, config, pkgs, ... }:
let defaults = config.modules.defaults;
in {
  config = lib.mkIf (lib.elem "k3s" defaults.roles) {
    boot.kernelParams =
      lib.optionals (pkgs.stdenv.hostPlatform.isAarch64) [
        "cgroup_memory=1"
        "cgroup_enable=cpuset"
        "cgroup_enable=memory"
      ];

    networking.firewall.allowedTCPPorts = [
      6443 # k3s: kubernetes API (TCP)
      2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
      2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
      10250 # k3s: Metrics Server (TCP)
    ];
    networking.firewall.allowedUDPPorts = [
      8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];
  };

}
