{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input: map toInt (splitString " " input);

  expandStone =
    cache: steps: stone:
    if steps == 0 then
      {
        inherit cache;
        ans = 1;
      }
    else if
      hasAttrByPath [
        (toString steps)
        (toString stone)
      ] cache
    then
      {
        cache = cache;
        ans = cache."${toString steps}"."${toString stone}";
      }
    else
      let
        len = stringLength (toString stone);
        subAns =
          if stone == 0 then
            expandStone cache (steps - 1) 1
          else if (mod len 2) == 0 then
            (foldl'
              (
                acc: stone:
                let
                  s = expandStone acc.cache (steps - 1) stone;
                in
                {
                  ans = acc.ans + s.ans;
                  cache = s.cache;
                }
              )
              {
                inherit cache;
                ans = 0;
              }
              [
                (stone / (pow 10 (len / 2)))
                (mod stone (pow 10 (len / 2)))
              ]
            )
          else
            expandStone cache (steps - 1) (stone * 2024);
      in
      {
        cache = force (
          recursiveUpdate subAns.cache {
            "${toString steps}" = {
              "${toString stone}" = subAns.ans;
            };
          }
        );
        ans = subAns.ans;
      };

  # brute force first
  bruteForce =
    stepsLeft: stones:
    foldl'
      (
        acc: el:
        let
          s = expandStone acc.cache stepsLeft el;
        in
        {
          cache = s.cache;
          ans = s.ans + acc.ans;
        }
      )
      {
        cache = { };
        ans = 0;
      }
      stones;

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    (bruteForce 25 p).ans;

  part2Answer =
    input:
    let
      p = parseInput input;
    in
    (bruteForce 75 p).ans;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
