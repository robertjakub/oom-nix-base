{
  config,
  lib,
  ...
}:
{
  vHost = {
    locations."/".proxyWebsockets = true;
    locations."/".extraConfig = ''
      proxy_set_header REMOTE_ADDR $remote_addr;
    '';
  };
}
.vHost
