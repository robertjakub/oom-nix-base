{ lib, config, ... }: {
  config = lib.mkIf config.services.openssh.openFirewall {
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
