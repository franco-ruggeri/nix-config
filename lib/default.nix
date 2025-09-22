{ pkgs }:

{
  mkConfigFiles = path:
    let
      dirs = builtins.attrNames (builtins.readDir path);
      toConfigDir = name: {
        name = name;
        value = {
          source = "${path}/${name}";
          recursive = true;
        };
      };
    in builtins.listToAttrs (map toConfigDir dirs);
}
