{ mylib, ... }:

{
  imports = [ ../common ../../../modules/user/darwin ];

  programs.aerospace.enable = true;

  xdg.configFile = mylib.mkConfigFiles ./config;
}
