{ config, pkgs, lib, ... }:
let cfg = config.modules.desktop.sound;
in {
  options.modules.desktop.sound.enable = lib.mkEnableOption "sound";

  config = lib.mkIf cfg.enable {
    # sound.enable = true;
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      # alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
      #media-session.enable = true;
    };
    environment.systemPackages = with pkgs; [
      pamixer
      alsa-utils
      pavucontrol
      wireplumber
    ];
  };
}
