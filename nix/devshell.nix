{
  nixpkgs,
  system,
  ...
}: let
  pkgs = import nixpkgs {inherit system;};
  wails3 = pkgs.callPackage ./wails3.nix {};
in {
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      go
      wails3
      gtk3
      webkitgtk_4_1
      pkg-config
    ];
    shellHook = with pkgs; ''
      export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS;
      export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/";
    '';
  };
}
