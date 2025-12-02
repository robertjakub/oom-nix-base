{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hm;
in {
  options.hm.git = {
    enable = mkEnableOption "home-manager/git";
    userName = mkOption {type = types.str;};
    userEmail = mkOption {type = types.str;};
    editor = mkOption {
      type = types.str;
      default = "nvim";
    };
    credHelper = mkOption {
      type = types.str;
      default = "cache";
    };
  };
  config = mkIf (cfg.git.enable) {
    programs.git = {
      enable = true;
      settings = {
        user = {
          email = cfg.git.userEmail;
          name = cfg.git.userName;
        };
        core = {
          quotepath = false;
          commitGraph = true;
          editor = cfg.git.editor;
        };
        gc = {
          writeCommitGraph = true;
        };
        credential = {
          helper = cfg.git.credHelper;
        };
        color = {
          ui = true;
        };
      };
    };
  };
}
