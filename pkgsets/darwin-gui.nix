{
  config,
  pkgs,
  ...
}: {
  config.modules.pkgsets.pkgsets.darwin-gui.pkgs = with pkgs; [
    # drawio # broken
    # kitty # broken
  ];
}
