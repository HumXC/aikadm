{pkgs, ...}: {
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      go
      wails
      nodejs
    ];
    shellHook = with pkgs; ''
      export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS;
      export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/";
    '';
  };
}
