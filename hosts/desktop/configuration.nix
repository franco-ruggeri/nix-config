{
  imports = [ ../../modules/system/nixos ];

  networking.hostName = "ruggeri-desktop";
  myModules.system.username = "franco";

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
