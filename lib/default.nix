{ pkgs, lib }:
rec {
  dotfilesConfigDir = ../dotfiles/config;
  dotfilesLocalDir = ../dotfiles/local;
  etcDir = ../etc;
  pythonDir = ../python;
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

  mkEtcFiles =
    paths:
    let
      mkEtcEntry = map (path: {
        name = path;
        value = {
          source = etcDir + "/${path}";
          recursive = true;
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
