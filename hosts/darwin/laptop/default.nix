{
  myModules.system = {
    username = "erugfra";
    tui.enable = true;
    gui.enable = true;
    nfs.backup = {
      enable = true;
      serverAddress = "10.34.0.2";
    };
  };

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = 6;
}
