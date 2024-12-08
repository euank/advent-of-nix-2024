let
  nixpkgs = import ./nixpkgs { };
  lib = import ./lib.nix { pkgs = nixpkgs; };
in
{
  day01 = import ./day01 { inherit nixpkgs lib; };
}
