nixpkgs: let
  lib = nixpkgs.lib;
in {
  cmdWithArgs = {
    aikadm,
    sessionDir ? [],
    env ? {},
    assets ? "",
    ...
  }:
    with lib;
      "${aikadm}/bin/aikadm"
      + (optionalString (sessionDir != []) (concatMapStrings (dir: " -d ${dir}") sessionDir))
      + (optionalString (env != {}) (concatMapStrings (e: " -e ${e}") (mapAttrsToList (k: v: k + "=" + (toString v)) env)))
      + (optionalString (assets != "") " -a ${assets}");
}
