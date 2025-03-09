{
  pkgs,
  html-greet,
  hyprlandPackage ? pkgs.hyprland,
  hyprConf ? "",
  ...
} @ args: let
  argv = import ./parse-argv.nix args;
  hyprConfFinal = pkgs.writeText "html-greet-hyprland-conf" ''
    exec-once = ${html-greet}/bin/html-greet ${argv}; ${hyprlandPackage}/bin/hyprctl dispatch exit
    ${hyprConf}
  '';
in
  pkgs.writeScript "html-greet-hyprland-script" ''
    ${hyprlandPackage}/bin/Hyprland --config ${hyprConfFinal}
  ''
