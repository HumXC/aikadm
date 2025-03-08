{
  pkgs,
  html-greet,
  hyprlandPackage ? pkgs.hyprland,
  hyprConf ? "",
  sessionDirs ? [],
  env ? {},
}:
with pkgs.lib; let
  argv =
    (optionalString (sessionDirs != []) (" -d \"" + (concatMapStrings (sessionDir: "${sessionDir};") sessionDirs) + "\""))
    + (optionalString (env != {}) (" -e \"" + (concatMapStrings (e: "${e};") (mapAttrsToList (k: v: k + "=" + (toString v)) env)) + "\""));

  hyprConfFinal = pkgs.writeText "html-greet-hyprland-conf" ''
    exec-once = ${html-greet}/bin/html-greet ${argv}; ${hyprlandPackage}/bin/hyprctl dispatch exit
    ${hyprConf}
  '';
in
  pkgs.writeScript "html-greet-hyprland-script" ''
    ${hyprlandPackage}/bin/Hyprland --config ${hyprConfFinal}
  ''
