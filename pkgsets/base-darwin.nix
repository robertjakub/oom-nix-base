{ config, pkgs, ... }: {
  config.modules.pkgsets.pkgsets.base-darwin.pkgs = with pkgs; [
    tmux
    git
    mc
    knot-dns
    dig
    socat
    fastfetch
    bottom
    gnupg
    pinentry-curses
    pass
    sshs
    wget
    aria2
    bwm_ng
    ipcalc
    p7zip
    btop
    jq
    attic-client
    yazi
  ];
}
