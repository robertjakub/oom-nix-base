{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf elem findFirst;
  inherit (lib) mkOption types;
  inherit ((findFirst (s: s.service == "gitea") config.modules config.modules.nginx.vHosts)) domain;
  cfg = config.modules.services;
  defSops = config.modules.defaults.sops.enable;
in
{
  options.modules.services.gitea = {
    enable = mkOption {
      type = types.bool;
      default = elem "gitea" cfg.services;
      description = "enable gitea";
    };
    http_addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "gitea: default addr";
    };
    http_port = mkOption {
      type = types.int;
      default = 9033;
      description = "gitea: default port";
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
      default = config.services.gitea.stateDir;
    };
  };

  config = mkIf (cfg.gitea.enable) {
    services.gitea = {
      enable = true;
      appName = "gitea";
      user = "git";
      database = {
        createDatabase = cfg.gitea.database.local;
        type = "postgres";
        host = cfg.gitea.database.host;
        port = cfg.gitea.database.port;
        user = "git";
        name = "git";
        passwordFile = mkIf defSops config.sops.secrets."services/gitea/dbPass".path;
      };
      settings = {
        service = {
          DISABLE_REGISTRATION = true;
          REGISTER_EMAIL_CONFIRM = false;
        };
        repository = {
          DISABLE_HTTP_GIT = false;
          USE_COMPAT_SSH_URI = true;
        };
        metrics = {
          ENABLED = true;
        };
        security = {
          INSTALL_LOCK = true;
          COOKIE_USERNAME = "gitea_username";
          COOKIE_REMEMBER_NAME = "gitea_userauth";
        };
        session = {
          cookieSecure = true;
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
          ALLOWED_DOMAINS = "*.trustno1.corp";
        };
        server = {
          DEFAULT_KEEP_EMAIL_PRIVATE = true;
          DISABLE_ROUTER_LOG = true;
          DISABLE_SSH = true;
          DOMAIN = cfg.gitea.domain;
          PROTOCOL = "http";
          ROOT_URL = "https://${cfg.gitea.domain}/";
          HTTP_PORT = cfg.gitea.http_port;
          HTTP_ADDR = cfg.gitea.http_addr;
        };
      };
    };

    # services.postgresql.ensureDatabases = ["git"];
    # services.postgresql.ensureUsers = [{ name = "git"; ensureDBOwnership = true; }];

    sops.secrets."services/gitea/dbPass" = mkIf defSops {
      owner = "git";
      group = "gitea";
    };

    users.users.git = {
      description = "Gitea Service";
      isNormalUser = true;
      home = config.services.gitea.stateDir;
      createHome = true;
      useDefaultShell = true;
    };
  };
}
