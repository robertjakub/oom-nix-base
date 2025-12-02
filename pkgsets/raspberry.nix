{
  config,
  pkgs,
  ...
}: {
  config.modules.pkgsets.pkgsets.raspberry.pkgs = with pkgs; [
    # libraspberrypi
    # raspberrypi-eeprom
    raspberrypifw
    ubootRaspberryPi4_64bit
    raspberrypi-armstubs
    flashrom
  ];
}
