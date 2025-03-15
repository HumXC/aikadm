{
  lib,
  frontend,
  makeWrapper,
  pkg-config,
  buildGoModule,
  glib-networking,
  gsettings-desktop-schemas,
  gtk3,
  webkitgtk_4_1,
  wails3,
  debug ? false,
}:
buildGoModule {
  pname = "html-greet";
  version = "0.0.1";

  src = ./..;

  vendorHash = "sha256-xP5qMj5H81n6JYZdyN6k0OdGHpDHCin/h1iNL4/KOuk=";
  nativeBuildInputs = [makeWrapper pkg-config wails3];
  proxyVendor = true;
  allowGoReference = true;
  buildInputs = [webkitgtk_4_1];
  tags =
    [
      "desktop"
      "production"
    ]
    ++ (lib.optional debug ["debug" "devtools"]);
  ldflags = [
    "-s"
    "-w"
  ];
  preBuild = ''
    mkdir frontend
    cp -r ${frontend}/share/html-greet-frontend/* frontend/
    wails3 generate bindings
  '';
  postBuild = ''
  '';
  # https://wails.io/docs/guides/nixos-font/
  postFixup = ''
    wrapProgram $out/bin/html-greet \
      --set XDG_DATA_DIRS ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS \
      --set GIO_MODULE_DIR ${glib-networking}/lib/gio/modules/
  '';
  meta = {
    description = "Build display manager using HTML + CSS + JS";
    homepage = "https://github.com/HumXC/html-greet";
    license = lib.licenses.mit;
    mainProgram = "html-greet";
    platforms = lib.platforms.unix;
  };
}
