{
  myModules.system = {
    username = "erugfra";
    tui.enable = true;
    gui.enable = true;
    nfs.client = {
      enable = true;
      serverAddress = "10.34.0.2";
    };
  };

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = 6;
}
