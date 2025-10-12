{ config, lib, ... }:
let
  cfg = config.myModules.system.wireguard;
in
{
  config = lib.mkIf cfg.enable {
    networking.wg-quick.interfaces.${cfg.device} = {
      address = [ cfg.address ];
      dns = [ cfg.dns ];
      privateKeyFile = cfg.privateKeyFile;
      peers = [
        {
          allowedIPs = cfg.allowedIPs;
          endpoint = cfg.endpoint;
          presharedKeyFile = cfg.presharedKeyFile;
          publicKey = cfg.serverPublicKey;
        }
      ];
    };
  };
}
