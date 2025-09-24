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
      configFiles = builtins.listToAttrs (map toConfigDir dirs);
    in configFiles;

  readJSON = filepath:
    builtins.fromJSON
    (builtins.unsafeDiscardStringContext (builtins.readFile filepath));
}
