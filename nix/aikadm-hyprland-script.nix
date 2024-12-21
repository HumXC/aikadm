{ pkgs
, aikadm ? pkgs.aikadm
, hyprlandPackage ? pkgs.hyprland
, hyprConf ? ""
, defaultUser ? ""
, defaultSession ? ""
, defaultMonitor ? 0
, wallpaperDir ? ""
, debug ? false
, sessionDirs ? [ ]
, env ? { }
}:
let
  argv = with pkgs.lib;
    (optionalString (defaultUser != "") "-u ${defaultUser} ") +
    (optionalString (defaultSession != "") "-s ${defaultSession} " +
    (optionalString (defaultMonitor != 0) "-m ${toString defaultMonitor} ") +
    (optionalString (wallpaperDir != "") "-w ${wallpaperDir} ") +
    (optionalString (debug != false) "--debug ") +
    (concatMapStrings (sessionDir: "-d ${sessionDir} ") sessionDirs) +
    (concatMapStrings (e: " -e " + e + " ") (
      attrsets.mapAttrsToList (k: v: k + "= " + (toString v)) env))
    )
  ;
  hyprConfFinal = pkgs.writeText "aika-greet-hyprland-conf" ''
    exec-once = ${aikadm}/bin/aikadm ${argv}; ${hyprlandPackage}/bin/hyprctl dispatch exit
    ${hyprConf}
  '';
in
pkgs.writeScript "aikadm-hyprland-script" ''
  ${hyprlandPackage}/bin/Hyprland --config ${hyprConfFinal} 
''
