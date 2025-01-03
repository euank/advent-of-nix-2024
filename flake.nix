{
  description = "Advent of code, 2024, solved with nix";

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = import ./lib.nix { pkgs = nixpkgs; };
      dayDirs = nixpkgs.lib.filterAttrs (name: _: nixpkgs.lib.hasPrefix "day" name) (
        builtins.readDir ./.
      );
    in
    {
      inherit lib nixpkgs;
      nixpkgs-src = "${nixpkgs}";
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      check = import ./check.nix { inherit nixpkgs lib; };
      tests = import ./tests { inherit nixpkgs lib; };
    }
    // (nixpkgs.lib.mapAttrs (name: _: import ./${name} { inherit nixpkgs lib; }) dayDirs);
}
