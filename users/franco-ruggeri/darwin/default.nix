{ myLib, ... }:

{
  imports = [ ../common ../../../modules/user/darwin ];

  programs.aerospace.enable = true;

  xdg.configFile = myLib.mkConfigFiles ./config;
}
