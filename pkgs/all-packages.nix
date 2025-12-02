{ system, self, ... }:
let pkgs = self.legacyPackages.${system};
in
{
  flame = pkgs.flame;
  passcore = pkgs.passcore;
  checkmate = pkgs.checkmate;
  checkmate-capture = pkgs.checkmate-capture;
  future-cyan-hyprcursor = pkgs.future-cyan-hyprcursor;
  graylog-7_0 = pkgs.graylog-7_0;
  graylog-enterprise-7_0 = pkgs.graylog-enterprise-7_0;
  graylog-forwarder-7_0 = pkgs.graylog-forwarder-7_0;
  graylog-sidecar = pkgs.graylog-sidecar;
  filebeat-9_2 = pkgs.filebeat-9_2;
  auditbeat-9_2 = pkgs.auditbeat-9_2;
  heartbeat-9_2 = pkgs.heartbeat-9_2;
  metricbeat-9_2 = pkgs.metricbeat-9_2;
  packetbeat-9_2 = pkgs.packetbeat-9_2;

}
