{ lib, ... }: {
  # workaround for https://github.com/NixOS/nixpkgs/issues/344963
  boot.initrd.systemd.tpm2.enable = false;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
