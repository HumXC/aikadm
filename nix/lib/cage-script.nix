{
  pkgs,
  html-greet,
  cagePackage ? pkgs.cage,
  cageEnv ? {},
  ...
} @ args: let
  argv = import ./parse-argv.nix args;
  cageEnvStr = with pkgs.lib; concatStringsSep " " (mapAttrsToList (k: v: k + "=" + v) cageEnv);
in
  pkgs.writeScript "html-greet-cage-script" ''
    ${cageEnvStr} ${cagePackage}/bin/cage -s -- ${html-greet}/bin/html-greet ${argv}
  ''
