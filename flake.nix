{
  description = "Advent of code, 2024, solved with nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      lib = import ./lib.nix { pkgs = nixpkgs; };
      dayDirs =
        nixpkgs.lib.filterAttrs (name: _: nixpkgs.lib.hasPrefix "day" name)
        (builtins.readDir ./.);
    in {
      inherit lib nixpkgs;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    } // (nixpkgs.lib.mapAttrs
      (name: _: import ./${name} { inherit nixpkgs lib; }) dayDirs);
}
