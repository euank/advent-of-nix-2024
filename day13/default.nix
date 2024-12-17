{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      parts = splitString "\n\n" input;
      parsePart =
        part:
        let
          lines = splitString "\n" part;
          a = builtins.match "^Button A: X\\+([0-9]+), Y\\+([0-9]+)$" (elemAt lines 0);
          b = builtins.match "^Button B: X\\+([0-9]+), Y\\+([0-9]+)$" (elemAt lines 1);
          p = builtins.match "^Prize: X=([0-9]+), Y=([0-9]+)$" (elemAt lines 2);
        in
        {
          a = {
            x = toInt (elemAt a 0);
            y = toInt (elemAt a 1);
          };
          b = {
            x = toInt (elemAt b 0);
            y = toInt (elemAt b 1);
          };
          prize = {
            x = toInt (elemAt p 0);
            y = toInt (elemAt p 1);
          };
        };
    in
    map parsePart parts;

  # We can binary search for this one pretty easily, so just do it
  solvePart =
    min: max: p:
    let
      a = (max + min) / 2;
      # So if we push 'a' N times, we push 'b' the remaining times needed to hit the score
      b = (p.prize.x - (a * p.a.x)) / p.b.x;
      score =
        if (p.a.x * a + p.b.x * b) == p.prize.x && (p.a.y * a + p.b.y * b) == p.prize.y then
          a * 3 + b
        else
          null;
      lScore = solvePart a max p;
      rScore = solvePart min a p;
    in
    if max == min then
      score
    else if (max - min) == 1 then
      score
    else
      foldl'
        (
          acc: el:
          if el != null && acc != null && el > acc then
            el
          else if el != null then
            el
          else
            acc
        )
        null
        [
          score
          lScore
          rScore
        ];

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' builtins.add 0 (remove null (map (solvePart 0 100) p));
in
{
  part1 = part1Answer input;
  #   part2 = part2Answer input;
}
