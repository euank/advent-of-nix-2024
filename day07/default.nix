{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      lines = splitString "\n" input;
      lines' = map (splitString ": ") lines;
    in
    map (lp: {
      total = toInt (head lp);
      # precompute divisors and non-divisors
      nums = map toInt ((splitString " ") (last lp));
    }) lines';

  # Brute-forcing feels like it should just work, so do that. Seems easiest.
  lineFactors =
    line:
    let
      ln = last line.nums;
      canDiv = (trivial.mod line.total ln) == 0;
    in
    if line.total == 0 && (length line.nums) == 0 then
      true
    else if (length line.nums) == 0 then
      false
    else if line.total <= 0 then
      false
    else if
      canDiv
      && lineFactors {
        total = line.total / ln;
        nums = init line.nums;
      }
    then
      true
    else
      lineFactors {
        total = line.total - ln;
        nums = init line.nums;
      };

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' (acc: el: acc + (if lineFactors el then el.total else 0)) 0 p;

  lineFactors2 =
    line:
    let
      ln = last line.nums;
      canDiv = (trivial.mod line.total ln) == 0;
    in
    if (length line.nums) == 1 then
      line.total == (head line.nums)
    else if (length line.nums) == 1 then
      false
    else if line.total <= 0 then
      false
    else
      canDiv
      && lineFactors2 {
        total = line.total / ln;
        nums = init line.nums;
      }
      || lineFactors2 {
        total = line.total - ln;
        nums = init line.nums;
      }
      || (
        ln != line.total
        && hasSuffix (toString ln) (toString line.total)
        && lineFactors2 {
          total = toInt (removeSuffix (toString ln) (toString line.total));
          nums = init line.nums;
        }
      );

  part2Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' (acc: el: acc + (if lineFactors2 el then el.total else 0)) 0 p;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
