{
  mkConfigDir =
    path:
    let
      entries = builtins.readDir path;
      dirs = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
      getConfigDir = name: {
        name = name;
        value = {
          source = "${path}/${name}";
          recursive = true;
        };
      };
      configFiles = builtins.listToAttrs (map getConfigDir dirs);
    in
    configFiles;

  mkSecrets =
    secretNames:
    let
      getSecret = name: {
        inherit name;
        value.file = ../secrets/${name}.age;
      };
      secrets = builtins.listToAttrs (map getSecret secretNames);
    in
    secrets;

  readJSON =
    filepath: builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile filepath));
}
