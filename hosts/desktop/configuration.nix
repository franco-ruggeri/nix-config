{
  imports = [ ../../modules/system/nixos ];

  myModules.system.username = "franco-ruggeri";

  # DO NOT change! Used for backward compatibility.
  system.stateVersion = "25.05";
}
