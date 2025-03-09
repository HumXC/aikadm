{
  lib,
  makeWrapper,
  pkg-config,
  buildGoModule,
  glib-networking,
  gsettings-desktop-schemas,
  gtk3,
  webkitgtk_4_0,
  wails,
  debug ? false,
}:
buildGoModule {
  pname = "html-greet";
  version = "0.0.1";

  src = ./..;

  vendorHash = "sha256-TNfL809d/rWAY8fETGEJjMcWv20Ijk6dqffzPU4Epqs=";
  nativeBuildInputs = [makeWrapper pkg-config wails];
  proxyVendor = true;
  allowGoReference = true;
  buildInputs = [webkitgtk_4_0];
  tags =
    [
      "desktop"
      "production"
    ]
    ++ (
      if debug
      then ["debug"]
      else []
    );
  ldflags = [
    "-s"
    "-w"
  ];
  preBuild = ''
    mkdir -p frontend/wailsjs
    # Make sure 'wails generate module' can work
    touch frontend/wailsjs/keep
    echo "{}" > wails.json
    wails generate module
    rm frontend/wailsjs/keep
  '';
  postBuild = ''
    rm -r frontend wails.json
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
