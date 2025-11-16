{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs;
  allowedIP = "10.34.0.0/24"; # only over VPN (secure)
  options = "rw";
in
{
  options.myModules.system.nfs = {
    enable = lib.mkEnableOption "Enable NFS server for homelab";
    path = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 2049 ];

    fileSystems."/srv/nfs/k8s" = {
      device = cfg.path;
      options = [ "bind" ];
    };

    services.nfs.server = {
      enable = true;
      exports = ''
        /srv/nfs ${allowedIP}(${options},fsid=0)
        /srv/nfs/k8s ${allowedIP}(${options})
      '';
    };
  };
}
