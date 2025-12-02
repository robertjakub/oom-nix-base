{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nginx;

  vHostConfigs = lib.listToAttrs (map
    (name: {
      name = lib.replaceStrings [ ".nix" ] [ "" ] name;
      value = import (./. + (lib.toPath "/nginx/${name}")) { inherit config lib pkgs; };
    })
    (lib.attrNames (builtins.readDir ./nginx)));

  mkVHost = vHost: {
    name = vHost.domain;
    value =
      let
        proxyPass =
          if (vHost.proxy != null) then { locations."/".proxyPass = vHost.proxy; } else { };
        redirectURL =
          if (vHost.redirect != null)
          then { locations."/".extraConfig = "return 301 ${vHost.redirect}$request_uri;"; }
          else { };
        attrs = lib.recursiveUpdate vHostConfigs."${vHost.service}" (proxyPass // redirectURL);
      in
      {
        enableACME = vHost.acme;
        addSSL = if (vHost.ssl && vHost.plain) then true else false;
        forceSSL = if (vHost.ssl && !vHost.plain) then true else false;
        acmeRoot = "/var/lib/acme/acme-challenge";
        root = vHost.root;
        serverAliases = vHost.aliases;
        listenAddresses = vHost.listenAddresses;
      }
      // attrs;
  };

  vHostsOpts = { config, ... }: {
    options = {
      service = lib.mkOption { type = lib.types.str; };
      domain = lib.mkOption { type = lib.types.str; };
      aliases = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
      proxy = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
      };
      ssl = lib.mkOption {
        type = lib.types.bool;
        default = cfg.defaults.ssl;
        description = "SSL port";
      };
      acme = lib.mkOption {
        type = lib.types.bool;
        default = cfg.defaults.acme;
        description = "ACME support";
      };
      plain = lib.mkOption {
        type = lib.types.bool;
        default = cfg.defaults.plain;
        description = "add non-SSL port";
      };
      root = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "webroot location";
      };
      redirect = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "vHost redirect url";
      };
      listenAddresses = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };
    };
  };
in
{
  options.modules.nginx = {
    enable = lib.mkEnableOption "nginx";
    openFirewall = lib.mkEnableOption "nginx: open default ports";
    vHosts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule [ vHostsOpts ]);
      default = [ ];
    };
    defaults.acme = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.defaults.acme.enable;
      description = "enable default ACME support";
    };
    defaults.ssl = lib.mkEnableOption "enable default ssl";
    defaults.plain = lib.mkEnableOption "enable default non-ssl support";
    defaults.listenAddresses = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "0.0.0.0" ]; # TODO: IPv6 FIXME
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = lib.mkDefault true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;
      sslCiphers = lib.mkDefault "ALL:!aNULL:EECDH+aRSA+AESGCM:EDH+aRSA:EECDH+aRSA:+AES256:+AES128:+SHA1:!CAMELLIA:!SEED:!3DES:!DES:!RC4:!eNULL";
      sslProtocols = lib.mkDefault "TLSv1.3 TLSv1.2"; # SSL

      commonHttpConfig = ''
        map $scheme $hsts_header {
          https "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
      '';
      defaultListenAddresses = cfg.defaults.listenAddresses;
      virtualHosts = lib.listToAttrs (map mkVHost cfg.vHosts);
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall) [ 80 443 ];
  };
}
