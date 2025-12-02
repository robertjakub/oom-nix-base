{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem concatMapStrings optionalString mkEnableOption mkOption types;
  cfg = config.modules.services;
in
{
  options.modules.services = {
    openssh.enable = mkOption {
      type = types.bool;
      default = elem "openssh" cfg.services;
      description = "enable openssh";
    };
    mosh.enable = mkEnableOption "enable mosh";
    openssh.passauth = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.openssh.enable) {
    programs.mosh.enable = cfg.mosh.enable;
    programs.ssh.enableAskPassword = false;
    services.openssh = {
      enable = true;
      sftpFlags = [ "-f AUTHPRIV" "-l INFO" ];
      settings = {
        KexAlgorithms = [ "sntrup761x25519-sha512" "mlkem768x25519-sha256" "curve25519-sha256@libssh.org" ];
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = cfg.openssh.passauth;
        PermitRootLogin = "prohibit-password"; # XXX FIXme
        X11Forwarding = false;
        UseDns = false;
      };
      extraConfig =
        let
          users =
            concatMapStrings (user: "${user.name} ") config.modules.users.users
            + (optionalString config.services.gitea.enable (config.services.gitea.user + " "))
            + "root "; # XXX FIXme
        in
        ''
          MaxSessions 64
          MaxStartups 128:30:512
          UsePAM no
          AllowUsers ${users}
          LogLevel VERBOSE
        '';
    };
  };
}
