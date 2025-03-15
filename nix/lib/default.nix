nixpkgs: let
  lib = nixpkgs.lib;
in {
  cmdWithArgs = {
    html-greet,
    sessionDir ? [],
    env ? {},
    assets ? "",
    ...
  }:
    with lib;
      "${html-greet}/bin/html-greet"
      + (optionalString (sessionDir != []) (concatMapStrings (dir: " -d ${dir}") sessionDir))
      + (optionalString (env != {}) (concatMapStrings (e: " -e ${e}") (mapAttrsToList (k: v: k + "=" + (toString v)) env)))
      + (optionalString (assets != "") " -a ${assets}");
}
