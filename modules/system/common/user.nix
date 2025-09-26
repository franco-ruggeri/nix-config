{ lib, ... }:
{
  options.myModules.system.username = lib.mkOption {
    type = lib.types.str;
    description = "The username of the main user.";
  };
}
