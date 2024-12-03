{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  part1Answer = input:
    let
      pieces = splitString "mul(" input;
      parsePiece = s:
        let matches = builtins.match "^([0-9]+),([0-9]+)\\).*$" s;
        in if matches == null || (length matches) != 2 then
          0
        else
          foldl' (acc: p: acc * p) 1 (map toInt matches);
    in foldl' builtins.add 0 (map parsePiece pieces);

in { part1 = part1Answer input; }
