# Steam provides a desktop entry with the PrefersNonDefaultGPU flag.
# That flag causes Steam to start on the wrong GPU on hybrid graphics systems.
# See https://github.com/ValveSoftware/steam-for-linux/issues/8983
#
# This override removes the PrefersNonDefaultGPU flag from the desktop entry.
{ steam-unwrapped }:
steam-unwrapped.overrideAttrs (old: {
  postInstall = old.postInstall + ''
    substituteInPlace $out/share/applications/steam.desktop \
      --replace "PrefersNonDefaultGPU=true" ""
  '';
})
