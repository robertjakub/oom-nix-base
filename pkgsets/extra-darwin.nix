{
  config,
  pkgs,
  ...
}: {
  config.modules.pkgsets.pkgsets.extra-darwin.pkgs = with pkgs; [
    lftp
    sops
    powershell
    yazi
  ];
}
