# We use autofs to mount the NFS export /k8s-backup on demand.
# Assumption: The user has added the following line to /etc/auto_master
# /Volumes/nfs auto_nfs -nobrowse,hidefromfinder,nosuid
{ config, lib, ... }:
let
  cfg = config.myModules.system.homelab.nfs.client;
in
{
  config = lib.mkIf cfg.enable {
    environment.etc."auto_nfs" = {
      text = ''
        k8s-nfs -fstype=nfs,vers=4,resvport 10.34.0.2:/k8s-nfs
        k8s-longhorn -fstype=nfs,vers=4,resvport 10.34.0.2:/k8s-longhorn
      '';
    };
  };
}
