{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      iparts = splitString "\n\n" input;
      lines =
        map (splitString ",") (splitString "\n" (builtins.elemAt iparts 1));
      badSequenceLookup = foldl' (acc: line:
        acc // {
          "${concatStringsSep "|" (reverseList (splitString "|" line))}" = true;
        }) { } (splitString "\n" (head iparts));
    in {
      badSeq = badSequenceLookup;
      inherit lines;
    };

  # So this one seems brute-forceable too, just do that :shrug:
  part1Answer = input:
    let
      p = parseInput input;

      isLineOkay = line:
        let
          calcLineCombos = num: rest:
            if (length rest) == 0 then
              [ ]
            else
              (map (el: "${num}|${el}") rest)
              ++ (calcLineCombos (head rest) (tail rest));
          lineCombos = line: calcLineCombos (head line) (tail line);
        in !(any (pair: p.badSeq ? "${pair}") (lineCombos line));
    in foldl' (acc: el:
      acc + (if (isLineOkay el) then
        toInt (builtins.elemAt el ((length el) / 2))
      else
        0)) 0 p.lines;
in {
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
