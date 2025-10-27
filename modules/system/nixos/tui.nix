{ config, lib, ... }:
let
  cfg = config.myModules.system.tui;
in
{
  config = lib.mkIf cfg.enable {
    users.users.${config.myModules.system.username}.extraGroups = [ "docker" ];

    # TODO: not sure it is needed... when devpod works, test it without this.
    networking = {
      firewall = {
        # For DevPod GPG server.
        # See https://github.com/loft-sh/devpod/issues/1562
        allowedTCPPorts = [ 12049 ];
        allowedUDPPorts = [ 12049 ];
      };
    };

    programs = {
      nix-ld.enable = true; # necessary for uv-managed Python
      gnupg.agent = {
        enable = true;
        enableExtraSocket = true; # necessary for DevPod GPG agent forwarding
        # WARNING: In the next NixOS version (>25.05):
        #   - Use gcr-ssh-agent as an SSH agent and remove this.
        #   - Delete ~/.gnupg/private-keys-v1.d/ (SSH keys are stored there)
        #   Reason:
        #   Using the GPG agent as an SSH agent is a workaround to make gnome-keyring work with SSH.
        #   The better solution would be to use the bundled SSH agent in gnome-keyring.
        #   However, gnome-keyring no longer includes an SSH agent. It's been moved to gcr-ssh-agent (gcr package).
        #   The current version 25.05 does not provide an option for it. The unstable version has fixed it.
        #   See https://github.com/NixOS/nixpkgs/pull/379731
        enableSSHSupport = true;
      };
    };

    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
    };

    virtualisation.docker.enable = true;
  };
}
