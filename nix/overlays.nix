{
  nixpkgs,
  aikadm-frontend,
  ...
}:
{
  default =
    self: super:
    let
      packages = import ./pkgs.nix {
        inherit nixpkgs aikadm-frontend;
        system = self.stdenv.hostPlatform.system;
      };
    in
    {
      aikadm = packages;
    };
}
