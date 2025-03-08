self: {
  pkgs,
  html-greetPackage ? self.packages.${pkgs.system}.html-greet,
  cagePackage ? pkgs.cage,
  cageEnv ? {},
  sessionDirs ? [],
  env ? {},
}:
with pkgs.lib; let
  argv =
    "-d"
    + (concatMapStrings (sessionDir: "${sessionDir};") sessionDirs)
    + " -e "
    + (concatMapStrings (e: e + ";") (mapAttrsToList (k: v: k + "=" + (toString v)) env));
  cageEnvStr = concatStringsSep " " (mapAttrsToList (k: v: k + "=" + v) cageEnv);
in
  pkgs.writeScript "aikadm-cage-script" ''
    ${cageEnvStr} ${cagePackage}/bin/cage -- ${html-greetPackage}/bin/aikadm ${argv}
  ''
