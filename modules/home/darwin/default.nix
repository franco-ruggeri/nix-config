{
  config,
  pkgs,
  myLib,
  ...
}:
{
  imports = [ ../common ];

  home = {
    username = config.myModules.home.username;
    homeDirectory = /Users/${config.myModules.home.username};

    packages = with pkgs; [ whatsapp-for-mac ];
  };

  programs = {
    aerospace.enable = true;
    gpg.enable = true;
  };

  xdg.configFile = myLib.mkConfigFiles ./config;
}
