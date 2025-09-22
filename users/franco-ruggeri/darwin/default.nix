{ pkgs, myLib, ... }:

{
  imports = [ ../common ../../../modules/user/darwin ];

  home.packages = with pkgs; [ whatsapp-for-mac ];

  programs.aerospace.enable = true;

  services.gpg-agent.enable = true;

  xdg.configFile = myLib.mkConfigFiles ./config;
}
