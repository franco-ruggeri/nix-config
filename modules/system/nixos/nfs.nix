{ config, lib, ... }:
let
  cfg = config.myModules.system.nfs;
  # TODO: make it secure. shouldn't be open to all
  # TODO: shouldn't be accessible via guest VPN...
  # TODO: check if this CIDR is needed and minimal
  mkBindMounts =
    paths:
    let
      mkBindMount = dest: src: {
        name = "/srv/nfs/${dest}";
        value = {
          device = src;
          options = [ "bind" ];
        };
      };
      mounts = builtins.listToAttrs (lib.mapAttrsToList mkBindMount paths);
    in
    mounts;
  mkExports =
    names:
    let
      allowedIPs = [ "10.43.0.0/16" ];
      options = "rw,sync";
      optionsRoot = "rw,fsid=root";
      mkAllowedIP = { allowedIP, options }: "${allowedIP}(${options})";
      mkAllowedIPs =
        options:
        lib.concatStringsSep " " (map (allowedIP: mkAllowedIP { inherit allowedIP options; }) allowedIPs);
      mkExport = name: "/srv/nfs/${name} ${mkAllowedIPs options}";
      exportRoot = "/srv/nfs ${mkAllowedIPs optionsRoot}";
      exportDirs = lib.concatStringsSep "\n" (map mkExport names);
      exports = exportRoot + "\n" + exportDirs;
    in
    exports;
in
{
  options.myModules.system.nfs = {
    enable = lib.mkEnableOption "Enable NFS server for homelab";
    paths = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Destination names to source paths for NFS exports";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 2049 ];

    fileSystems = mkBindMounts cfg.paths;

    services.nfs.server = {
      enable = true;
      exports = mkExports (lib.attrNames cfg.paths);
    };
  };
}
