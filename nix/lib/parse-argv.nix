{
  pkgs,
  sessionDir ? [],
  env ? {},
  assets ? "",
  ...
}:
with pkgs.lib;
  "" # 为了对齐
  + (optionalString (sessionDir != []) (concatMapStrings (dir: " -d ${dir}") sessionDir))
  + (optionalString (env != {}) (concatMapStrings (e: " -e ${e}") (mapAttrsToList (k: v: k + "=" + (toString v)) env)))
  + (optionalString (assets != "") " -a ${assets}")
