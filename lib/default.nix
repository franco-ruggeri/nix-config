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
    path:
    let
      entries = builtins.readDir path;
      files = builtins.filter (name: entries.${name} == "regular") (builtins.attrNames entries);
      ageFiles = builtins.filter (name: (builtins.match ".*\.age$" name) != null) files;
      getSecret = file: {
        name = builtins.replaceStrings [ ".age" ] [ "" ] file;
        value.file = path + "/${file}";
      };
      secrets = builtins.listToAttrs (map getSecret ageFiles);
    in
    secrets;

  readJSON =
    filepath: builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile filepath));
}
