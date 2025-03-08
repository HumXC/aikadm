{pkgs, ...}: {
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      go
      wails
      nodejs
    ];
  };
}
