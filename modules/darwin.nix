{ lib, ... }:
let fn = import ./lib/internal.nix { inherit lib; };
in
{
  imports = [ ./base.nix ] ++ (fn.scanPaths ./darwin);

  security.pam.services.sudo_local.touchIdAuth = lib.mkDefault true;

  system.stateVersion = lib.mkDefault 6;
  system.defaults = {
    dock.autohide = lib.mkDefault false;
    dock.autohide-delay = lib.mkDefault 0.10;
    dock.mru-spaces = lib.mkDefault false;
    # finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = lib.mkDefault "clmv";
    loginwindow.LoginwindowText = lib.mkDefault "TrustNo1 (part of ACME)";
    universalaccess.mouseDriverCursorSize = lib.mkDefault 2.5;
    # screencapture.location = "~/Pictures/screenshots";
    # screensaver.askForPasswordDelay = 10;
  };
}
