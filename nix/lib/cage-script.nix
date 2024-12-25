self:
{ pkgs
, aikadmPackage ? self.packages.${pkgs.system}.aikadm
, cagePackage ? pkgs.cage
, cageEnv ? { }
, wallpaperDir ? ""
, sessionDirs ? [ ]
, env ? { }
}:
with pkgs.lib;
let
  argv =
    (optionalString (wallpaperDir != "") "-w ${wallpaperDir} ") +
    (concatMapStrings (sessionDir: "-d ${sessionDir} ") sessionDirs) +
    (concatMapStrings (e: " -e " + e + " ") (mapAttrsToList (k: v: k + "=" + (toString v)) env));
  cageEnvStr = concatStringsSep " " (mapAttrsToList (k: v: k + "=" + v) cageEnv);
in
pkgs.writeScript "aikadm-cage-script" ''
  ${cagePackage}/bin/cage -- ${cageEnvStr} ${aikadmPackage}/bin/aikadm ${argv}
''
