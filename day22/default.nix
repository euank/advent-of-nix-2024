{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input: map toInt (splitString "\n" input);

  prune = n: mod n 16777216;
  mix = a: b: builtins.bitXor a b;

  step =
    num:
    let
      i1 = prune (mix num (num * 64));
      i2 = prune (mix i1 (i1 / 32));
      i3 = prune (mix i2 (i2 * 2048));
    in
    i3;

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' builtins.add 0 (map (n: foldl' (acc: el: step acc) n (builtins.genList trivial.id 2000)) p);

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
