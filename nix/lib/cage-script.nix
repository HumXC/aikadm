self:
{ pkgs
, aikadmPackage ? self.packages.${pkgs.system}.aikadm
, cagePackage ? pkgs.cage
, wallpaperDir ? ""
, sessionDirs ? [ ]
, env ? { }
}:
let
  argv = with pkgs.lib;
    (optionalString (wallpaperDir != "") "-w ${wallpaperDir} ") +
    (concatMapStrings (sessionDir: "-d ${sessionDir} ") sessionDirs) +
    (concatMapStrings (e: " -e " + e + " ") (attrsets.mapAttrsToList (k: v: k + "= " + (toString v)) env));
in
pkgs.writeScript "aikadm-cage-script" ''
  ${cagePackage}/bin/cage -- ${aikadmPackage}/bin/aikadm ${argv}
''
