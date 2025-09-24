{
  config,
  pkgs,
  lib,
  ...
}:
# TODO: taken from wiki, need to check it... manual was simpler than wiki but didn't work
let
  kubeMasterIP = "127.0.0.1";
  kubeMasterHostname = "kubernetes";
  kubeMasterAPIServerPort = 6443;
in
{
  options.system.kubernetes.enable = lib.mkEnableOption "Kubernetes master and worker";

  config = lib.mkIf config.system.kubernetes.enable {
    networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";
    environment.systemPackages = with pkgs; [
      kompose
      kubectl
      kubernetes
    ];
    services.kubernetes = {
      roles = [
        "master"
        "node"
      ];
      masterAddress = kubeMasterHostname;
      apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
      easyCerts = true;
      apiserver = {
        securePort = kubeMasterAPIServerPort;
        advertiseAddress = kubeMasterIP;
        # TODO: this is insecure, it should be the default but I'm having troubles with it, so for now I'm using this value
        authorizationMode = [ "AlwaysAllow" ];
      };
      addons.dns.enable = true;
    };
  };
}
