{ myLib, ... }:

{
  imports = [ ../common ../../../modules/user/darwin ];

  programs.aerospace.enable = true;

  services.gpg-agent.enable = true;

  xdg.configFile = myLib.mkConfigFiles ./config;
}
