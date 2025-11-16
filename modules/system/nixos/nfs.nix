{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs;
  # TODO: make it secure. shouldn't be open to all
  # TODO: shouldn't be accessible via guest VPN...
in
{
  options.myModules.system.nfs = {
    enable = lib.mkEnableOption "Enable NFS server for homelab";
    path = lib.mkOption {
      type = lib.types.str;
      description = "Path to export";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 2049 ];

    fileSystems."/srv/nfs/k8s" = {
      device = cfg.path;
      options = [ "bind" ];
    };

    services.nfs.server = {
      enable = true;
      exports = "/srv/nfs/k8s 192.168.1.0/24(rw)";
    };
  };
}
