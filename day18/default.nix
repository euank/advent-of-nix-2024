{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      lines = splitString "\n" input;
    in map (line: map toInt (splitString "," line)) lines;

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    p;

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
