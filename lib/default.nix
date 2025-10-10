{ pkgs, lib }:
rec {
  dotfilesConfigDir = ../dotfiles/config;
  dotfilesLocalDir = ../dotfiles/local;
  secretsDir = ../secrets;

  mkConfigDotfiles =
    paths:
    let
      mkConfigDir = map (path: {
        name = path;
        value = {
          source = dotfilesConfigDir + "/${path}";
          recursive = true;
        };
      });
      dotfiles = builtins.listToAttrs (mkConfigDir paths);
    in
    dotfiles;

  mkLocalDotfiles =
    paths:
    let
      mkLocalDir = map (path: {
        name = ".local/${path}";
        value = {
          source = dotfilesLocalDir + "/${path}";
          recursive = true;
        };
      });
      dotfiles = builtins.listToAttrs (mkLocalDir paths);
    in
    dotfiles;

  fromJSON = file: builtins.fromJSON (builtins.unsafeDiscardStringContext file);

  mkSecrets =
    names:
    let
      mkSecret = name: {
        inherit name;
        value.file = secretsDir + "/${name}.age";
      };
      secrets = builtins.listToAttrs (map mkSecret names);
    in
    secrets;

  mkWireguardSecrets =
    names:
    let
      mkSecret = name: {
        inherit name;
        value = {
          file = secretsDir + "/${name}.age";
          mode = "640";
          owner = "systemd-network";
          group = "systemd-network";
        };
      };
      secrets = builtins.listToAttrs (map mkSecret names);
    in
    secrets;

  isDarwin = lib.strings.hasSuffix "darwin" pkgs.system;
  isLinux = lib.strings.hasSuffix "linux" pkgs.system;
}
