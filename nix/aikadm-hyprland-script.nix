{ pkgs
, aikadm
, hyprlandPackage ? pkgs.hyprland
, hyprConf ? ""
, wallpaperDir ? ""
, sessionDirs ? [ ]
, env ? { }
}:
let
  argv = with pkgs.lib;
    (optionalString (wallpaperDir != "") "-w ${wallpaperDir} ") +
    (concatMapStrings (sessionDir: "-d ${sessionDir} ") sessionDirs) +
    (concatMapStrings (e: " -e " + e + " ") (attrsets.mapAttrsToList (k: v: k + "= " + (toString v)) env));

  hyprConfFinal = pkgs.writeText "aika-greet-hyprland-conf" ''
    exec-once = ${aikadm}/bin/aikadm ${argv}; ${hyprlandPackage}/bin/hyprctl dispatch exit
    ${hyprConf}
  '';
in
pkgs.writeScript "aikadm-hyprland-script" ''
  ${hyprlandPackage}/bin/Hyprland --config ${hyprConfFinal} 
''
