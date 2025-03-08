self: {
  pkgs,
  html-greetPackage ? self.packages.${pkgs.system}.html-greet,
  hyprlandPackage ? pkgs.hyprland,
  hyprConf ? "",
  sessionDirs ? [],
  env ? {},
}: let
  argv = with pkgs.lib;
    "-d"
    + (concatMapStrings (sessionDir: "${sessionDir};") sessionDirs)
    + " -e "
    + (concatMapStrings (e: e + ";") (mapAttrsToList (k: v: k + "=" + (toString v)) env));

  hyprConfFinal = pkgs.writeText "html-greet-hyprland-conf" ''
    exec-once = ${html-greetPackage}/bin/html-greet ${argv}; ${hyprlandPackage}/bin/hyprctl dispatch exit
    ${hyprConf}
  '';
in
  pkgs.writeScript "html-greet-hyprland-script" ''
    ${hyprlandPackage}/bin/Hyprland --config ${hyprConfFinal}
  ''
