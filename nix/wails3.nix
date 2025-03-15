{
  wails,
  fetchFromGitHub,
  lib,
  stdenv,
  go,
  pkg-config,
  gtk3,
  webkitgtk_4_1,
  zlib,
  ...
}:
wails.overrideAttrs (oldAttrs: rec {
  pname = "wails3";
  version = "3.0.0-alpha.9";
  src =
    fetchFromGitHub {
      owner = "wailsapp";
      repo = "wails";
      rev = "v${version}";
      hash = "sha256-3sXR3dPpMU9S01/STTzKvju8Pvkq4+Ve7Fo2eMKsYN0=";
    }
    + "/v3";
  propagatedBuildInputs =
    [
      pkg-config
      go
      stdenv.cc
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      gtk3
      webkitgtk_4_1
    ];

  vendorHash = "sha256-yU/v0fDw7OoF51JkHzN8jFw3eG4nA42TD6kuuLF65jw=";

  proxyVendor = true;

  subPackages = ["cmd/wails3"];
  postFixup = ''
    wrapProgram $out/bin/wails3 \
      --prefix PATH : ${
      lib.makeBinPath [
        pkg-config
        go
        stdenv.cc
      ]
    } \
      --prefix LD_LIBRARY_PATH : "${
      lib.makeLibraryPath (
        lib.optionals stdenv.hostPlatform.isLinux [
          gtk3
          webkitgtk_4_1
        ]
      )
    }" \
      --set PKG_CONFIG_PATH "$PKG_CONFIG_PATH" \
      --set CGO_LDFLAGS "-L${lib.makeLibraryPath [zlib]}"
  '';
})
