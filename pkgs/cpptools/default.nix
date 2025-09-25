# With the vscode-extensions.ms-vscode.cpptools Nix package, OpenDebugAD7 is
# not in PATH and cannot be easily launched. This derivation solves that
# problem by creating a symlink to it in `bin/`.
{ pkgs, stdenv, ... }:
stdenv.mkDerivation {
  pname = "cpptools";
  version = "1.0";
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7 $out/bin/
  '';
}
