# With the vscode-extensions.ms-vscode.cpptools Nix package, OpenDebugAD7 is
# not in PATH and cannot be easily launched.
#
# This override creates a symlink to OpenDebugAD7 in $out/bin.
{ cpptools }:
cpptools.overrideAttrs (old: {
  postInstall = ''
    mkdir -p $out/bin
    ln -s ${cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7 $out/bin/
  '';
})
