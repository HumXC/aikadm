{
  lib,
  go,
  wails,
  nodejs,
  buildGoModule,
}:
buildGoModule {
  pname = "html-greet";
  version = "0.0.1";

  src = ./..;

  vendorHash = "sha256-9zeLUuI8QY/twQEad0fVLwEmWj4R6adPfchO5/z2r3Y=";

  proxyVendor = true;
  allowGoReference = true;

  nativeBuildInputs = [
    wails
    nodejs
  ];
  # TODO: Package
  buildPhase = ''
    wails build
  '';
  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Build display manager using HTML + CSS + JS";
    homepage = "https://github.com/HumXC/html-greet";
    license = lib.licenses.mit;
    mainProgram = "html-greet";
    platforms = lib.platforms.unix;
  };
}
