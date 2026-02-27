{ pkgs, lib }:
rec {
  dotfilesConfigDir = ../dotfiles/config;
  dotfilesLocalDir = ../dotfiles/local;
  scriptsDir = ../scripts;
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

  mkShellScript =
    name:
    let
      path = scriptsDir + "/${name}";
      file = builtins.readFile path;
      script = pkgs.writeShellScript name file;
    in
    script;

  mkPythonScriptDir =
    { derivationName, scriptNames }:
    let
      deriv = pkgs.stdenv.mkDerivation {
        name = derivationName;
        src = scriptsDir;
        installPhase = ''
          mkdir -p $out
          for script in ${toString scriptNames}; do
            cp $script $out
            chmod +x $out/$script
          done
        '';
      };
    in
    deriv;

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
