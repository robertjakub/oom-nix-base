{ config, pkgs, lib, ... }:
let cfg = config.modules.desktop;
in {
  options.modules.desktop.fonts = {
    enable = lib.mkEnableOption "gnome";
  };

  config = lib.mkIf (cfg.enable && cfg.fonts.enable) {
    fonts = {
      fontconfig.hinting.autohint = true;
      fontDir.enable = true;
      packages = [ ]
        # [ pkgs.oom-base.applefonts ] # FIXME
        ++ (with pkgs; [
        lato
        helvetica-neue-lt-std
        liberation_ttf
        corefonts
        vista-fonts
        font-awesome
        fira
        raleway
        # martian-mono # FIXME
        nerd-fonts.droid-sans-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.fira-mono
        nerd-fonts.symbols-only
      ]);
    };
  };
}
