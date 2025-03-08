{
  pkgs,
  html-greet,
  cagePackage ? pkgs.cage,
  cageEnv ? {},
  sessionDirs ? [],
  env ? {},
}:
with pkgs.lib; let
  argv =
    (optionalString (sessionDirs != []) (" -d \"" + (concatMapStrings (sessionDir: "${sessionDir};") sessionDirs) + "\""))
    + (optionalString (env != {}) (" -e \"" + (concatMapStrings (e: "${e};") (mapAttrsToList (k: v: k + "=" + (toString v)) env)) + "\""));

  cageEnvStr = concatStringsSep " " (mapAttrsToList (k: v: k + "=" + v) cageEnv);
in
  pkgs.writeScript "html-greet-cage-script" ''
    ${cageEnvStr} ${cagePackage}/bin/cage -- ${html-greet}/bin/html-greet ${argv}
  ''
