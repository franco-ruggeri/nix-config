{
  # TODO: can I import submodules based on OS? if so, the clients can just import this one instead of the submodules
  # e.g. default.nix imports ./common
  #  ./darwin, and hosts/laptop will imports ../../modules/system (1 import
  #    instead of 2)
  # If I manage to do so, I can restructure all the modules to simplify importing.
}
