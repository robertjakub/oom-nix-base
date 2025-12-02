{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf elem findFirst;
  inherit (lib) mkOption types mkDefault;
  inherit ((findFirst (s: s.service == "forgejo") config.modules config.modules.nginx.vHosts)) domain;
  cfg = config.modules.services;
  defSops = config.modules.defaults.sops.enable;
in
{
  options.modules.services.forgejo = {
    enable = mkOption {
      type = types.bool;
      default = elem "forgejo" cfg.services;
      description = "enable forgejo";
    };
    http_addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "forgejo: default addr";
    };
    http_port = mkOption {
      type = types.int;
      default = 9033;
      description = "forgejo: default port";
    };
    domain = mkOption {
      type = types.str;
      default = domain;
    };
    database.local = mkOption {
      type = types.bool;
      default = false;
    };
    database.host = mkOption {
      type = types.str;
      default = "/run/postgresql";
    };
    database.port = mkOption {
      type = types.int;
      default = 5432;
    };
    stateDir = mkOption {
      type = types.str;
      default = config.services.forgejo.stateDir;
    };
  };

  config = mkIf (cfg.forgejo.enable) {
    services.forgejo = {
      enable = true;
      user = "git";
      database = {
        createDatabase = cfg.forgejo.database.local;
        type = "postgres";
        host = cfg.forgejo.database.host;
        port = cfg.forgejo.database.port;
        user = "git";
        name = "git";
        passwordFile = mkIf defSops config.sops.secrets."services/forgejo/dbPass".path;
      };
      settings = {
        DEFAULT = {
          APP_NAME = mkDefault "forgejo";
        };
        service = {
          DISABLE_REGISTRATION = mkDefault true;
          REGISTER_EMAIL_CONFIRM = mkDefault false;
        };
        repository = {
          DISABLE_HTTP_GIT = mkDefault false;
          USE_COMPAT_SSH_URI = mkDefault true;
        };
        metrics = {
          ENABLED = mkDefault true;
        };
        security = {
          INSTALL_LOCK = mkDefault true;
          COOKIE_REMEMBER_NAME = mkDefault "forgejo_userauth";
        };
        session = {
          cookieSecure = mkDefault true;
        };
        "markup.restructuredtext" =
          let
            docutils = pkgs.python3.withPackages (ps: with ps; [ docutils pygments ]);
          in
          {
            ENABLED = true;
            FILE_EXTENSIONS = ".rst";
            RENDER_COMMAND = "${docutils}/bin/rst2html.py";
            IS_INPUT_FILE = false;
          };
        migrations = {
          ALLOWED_DOMAINS = mkDefault "*.trustno1.corp";
        };
        ui = {
          SHOW_USER_EMAIL = mkDefault false;
          DEFAULT_THEME = mkDefault "forgejo-dark";
        };
        server = {
          DEFAULT_KEEP_EMAIL_PRIVATE = mkDefault true;
          DISABLE_ROUTER_LOG = mkDefault true;
          DISABLE_SSH = mkDefault true;
          DOMAIN = mkDefault cfg.forgejo.domain;
          PROTOCOL = mkDefault "http";
          ROOT_URL = mkDefault "https://${cfg.forgejo.domain}/";
          HTTP_PORT = cfg.forgejo.http_port;
          HTTP_ADDR = cfg.forgejo.http_addr;
        };
      };
    };

    # services.postgresql.ensureDatabases = ["git"];
    # services.postgresql.ensureUsers = [{ name = "git"; ensureDBOwnership = true; }];

    sops.secrets."services/forgejo/dbPass" = mkIf defSops {
      owner = "git";
      group = "forgejo";
    };

    users = {
      groups.forgejo.gid = config.ids.gids.git;
      users.git = {
        uid = config.ids.uids.git;
        description = "Forgejo daemon user";
        home = config.services.forgejo.stateDir;
        group = "forgejo";
        useDefaultShell = true;
      };
    };
  };
}
