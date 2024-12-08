{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      iparts = splitString "\n\n" input;
      lines = map (splitString ",") (splitString "\n" (builtins.elemAt iparts 1));
      badSequenceLookup = foldl' (
        acc: line:
        acc
        // {
          "${concatStringsSep "|" (reverseList (splitString "|" line))}" = true;
        }
      ) { } (splitString "\n" (head iparts));
    in
    {
      badSeq = badSequenceLookup;
      inherit lines;
    };

  calcLineCombos =
    num: rest:
    if (length rest) == 0 then
      [ ]
    else
      (map (el: "${num}|${el}") rest) ++ (calcLineCombos (head rest) (tail rest));
  lineCombos = line: calcLineCombos (head line) (tail line);

  # So this one seems brute-forceable too, just do that :shrug:
  part1Answer =
    input:
    let
      p = parseInput input;

      isLineOkay =
        line:
        let
        in
        !(any (pair: p.badSeq ? "${pair}") (lineCombos line));
    in
    foldl' (
      acc: el: acc + (if (isLineOkay el) then toInt (builtins.elemAt el ((length el) / 2)) else 0)
    ) 0 p.lines;

  part2Answer =
    input:
    let
      p = parseInput input;
      p1Answer = part1Answer input;

      fixLine =
        line:
        let
          iline = imap0 (i: char: { inherit i char; }) line;
          firstBad = findFirst (pair: p.badSeq ? "${pair}") null (lineCombos line);
        in
        if firstBad == null then
          line
        # Otherwise, swap the bad pair and try again
        else
          let
            badEl = splitString "|" firstBad;
            swapped = swap line ((findFirst (el: el.char == (head badEl)) null iline).i) (
              (findFirst (el: el.char == (elemAt badEl 1)) null iline).i
            );
          in
          fixLine swapped;
    in
    (foldl' (acc: el: acc + (toInt (builtins.elemAt (fixLine el) ((length el) / 2)))) 0 p.lines)
    - p1Answer;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
