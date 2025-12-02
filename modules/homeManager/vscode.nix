{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hm;
in {
  options.hm.vscode = {
    enable = mkEnableOption "home-manager/vscode";
    fontSize = mkOption {
      type = types.int;
      default = 14;
    };
    fontFamily = mkOption {
      type = types.str;
      default = "'JetBrainsMonoNL NFP ExtraLight'";
    };
    zoomLevel = mkOption {
      type = types.float;
      default = 1.0;
    };
    indent = mkOption {
      type = types.int;
      default = 20;
    };
  };
  config = mkIf (cfg.vscode.enable) {
    programs.vscode = {
      enable = true;
      mutableExtensionsDir = true;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions =
          (with pkgs.vscode-extensions; [
            oderwat.indent-rainbow
            bbenoist.nix
            mechatroner.rainbow-csv
            ms-vscode.powershell
            # ms-python.python
          ])
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "sops-edit";
              publisher = "shipitsmarter";
              version = "1.0.0";
              sha256 = "sha256-BGuzmr3o0lxsFKjv2uPbK07sVQnDp9X6M+5mHuFMXyw=";
            }
          ];
        userSettings = {
          "window.zoomLevel" = cfg.vscode.zoomLevel;
          "editor.fontSize" = cfg.vscode.fontSize;
          "editor.fontLigatures" = true;
          "workbench.startupEditor" = "none";
          "workbench.tree.indent" = cfg.vscode.indent;
          "workbench.tree.renderIndentGuides" = "always";
          "telemetry.telemetryLevel" = "off";
          "update.showReleaseNotes" = false;
          "editor.tabSize" = 2;
          "editor.minimap.enabled" = false;
          "editor.fontFamily" = cfg.vscode.fontFamily;
          "extensions.autoCheckUpdates" = false;
          "extensions.autoUpdate" = false;
          "update.mode" = "none";
          "powershell.powerShellAdditionalExePaths" = {
            "pwsh" = "/run/current-system/sw/bin/pwsh";
          };
        };
      };
    };
  };
}
