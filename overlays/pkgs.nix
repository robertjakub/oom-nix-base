self: super: {
  # final: prev:
  flame = super.callPackage ../pkgs/flame { };
  passcore = super.callPackage ../pkgs/passcore { };
  graylog-7_0 = super.callPackage ../pkgs/graylog/7.0.nix { };
  graylog-enterprise-7_0 = super.callPackage ../pkgs/graylog-enterprise/7.0.nix { };
  graylog-forwarder-7_0 = super.callPackage ../pkgs/graylog-forwarder/7.0.nix { };
  checkmate = super.callPackage ../pkgs/checkmate { };
  checkmate-capture = super.callPackage ../pkgs/checkmate-capture { };
  future-cyan-hyprcursor = super.callPackage ../pkgs/future-cyan-hyprcursor { };
  graylog-sidecar = super.callPackage ../pkgs/graylog-sidecar/package.nix { };
  filebeat-9_2 = (super.callPackages ../pkgs/beats/9.2.nix { }).filebeat;
  auditbeat-9_2 = (super.callPackages ../pkgs/beats/9.2.nix { }).auditbeat;
  heartbeat-9_2 = (super.callPackages ../pkgs/beats/9.2.nix { }).heartbeat;
  metricbeat-9_2 = (super.callPackages ../pkgs/beats/9.2.nix { }).metricbeat;
  packetbeat-9_2 = (super.callPackages ../pkgs/beats/9.2.nix { }).packetbeat;

}
