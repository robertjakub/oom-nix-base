{ self, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      oom-base = import self.inputs.nixpkgs {
        system = prev.stdenv.hostPlatform.system;
        config = { inherit (prev.config) allowUnfree allowUnfreePredicate; };
        overlays = [ self.overlays.pkgs ];
      };
    })
  ];
}
