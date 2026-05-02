{ pkgs, lib }:
rec {
  dotfilesDir = ../files/dot;
  etcDir = ../files/etc;
  pythonDir = ../python;
  secretsDir = ../secrets;

  mkLocalFiles =
    paths:
    let
      mkDotfilesEntry = map (path: {
        name = ".local/${path}";
        value = {
          source = dotfilesDir + "/local/${path}";
          recursive = true;
        };
      });
      dotfiles = builtins.listToAttrs (mkDotfilesEntry paths);
    in
    dotfiles;

  mkConfigFiles =
    paths:
    let
      mkDotfilesEntry = map (path: {
        name = path;
        value = {
          source = dotfilesDir + "/config/${path}";
          recursive = true;
        };
      });
      dotfiles = builtins.listToAttrs (mkDotfilesEntry paths);
    in
    dotfiles;

  mkEtcFiles =
    paths:
    let
      mkEtcEntry = map (path: {
        name = path;
        value = {
          source = etcDir + "/${path}";
        };
      });
      etcFiles = builtins.listToAttrs (mkEtcEntry paths);
    in
    etcFiles;

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

  mkShellScript =
    name:
    let
      path = pythonDir + "/${name}";
      file = builtins.readFile path;
      script = pkgs.writeShellScript name file;
    in
    script;

  mkPythonApplication =
    name:
    pkgs.python3Packages.buildPythonApplication {
      pname = name;
      version = "0.1.0";
      pyproject = true;
      src = pythonDir + "/${name}";
      build-system = [ pkgs.python3Packages.hatchling ];
    };

  mkNfsExport =
    {
      allowedIPs,
      options,
    }:
    let
      allowedIPWithOptions = map (ip: "${ip}(${options})") allowedIPs;
      export = "${lib.concatStringsSep " " allowedIPWithOptions}";
    in
    export;

  isDarwin = lib.strings.hasSuffix "darwin" pkgs.system;
  isLinux = lib.strings.hasSuffix "linux" pkgs.system;
}
