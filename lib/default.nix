{ pkgs, lib }:
{
  mkConfigDotfiles =
    paths:
    let
      mkConfigDir = map (path: {
        name = path;
        value = {
          source = ../dotfiles/config/${path};
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
          source = ../dotfiles/local/${path};
          recursive = true;
        };
      });
      dotfiles = builtins.listToAttrs (mkLocalDir paths);
    in
    dotfiles;

  readConfigDotfile = filepath: builtins.readFile ../dotfiles/config/${filepath};

  fromJSON = file: builtins.fromJSON (builtins.unsafeDiscardStringContext file);

  mkSecrets =
    secretNames:
    let
      mkSecret = name: {
        inherit name;
        value.file = ../secrets/${name}.age;
      };
      secrets = builtins.listToAttrs (map mkSecret secretNames);
    in
    secrets;

  isDarwin = lib.strings.hasSuffix "darwin" pkgs.system;
  isLinux = lib.strings.hasSuffix "linux" pkgs.system;
}
