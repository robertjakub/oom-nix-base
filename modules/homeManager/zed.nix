{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hm;
in {
  options.hm.zed = {
    enable = mkEnableOption "home-manager/zed";
    fontSize = mkOption {
      type = types.int;
      default = 14;
    };
    UIfontSize = mkOption {
      type = types.int;
      default = cfg.zed.fontSize;
    };
  };
  config = mkIf (cfg.zed.enable) {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        features = {copilot = false;};
        telemetry = {metrics = false;};
        vim_mode = false;
        ui_font_size = cfg.zed.UIfontSize;
        buffer_font_size = cfg.zed.fontSize;
        theme = "Ayu Dark";
        base_keymap = "VSCode";
        cursor_shape = "block";
        tab_size = 2;
        hard_tabs = true;
        languages = {
          Nix.language_servers = ["nil" "!nixd"];
        };
        lsp.nil.settings = {
          formatting.command = ["${pkgs.alejandra}/bin/alejandra"];
        };
      };
      extensions = ["nix" "xml" "lua"];
    };
  };
}
