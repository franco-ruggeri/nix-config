{ pkgs, myLib, ... }:

{
  imports = [ ../common ../../../modules/user/darwin ];

  home.packages = with pkgs; [ whatsapp-for-mac ];

  programs = {
    aerospace.enable = true;
    gpg.enable = true;
  };

  xdg.configFile = myLib.mkConfigFiles ./config;
}
