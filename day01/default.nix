{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  # input -> [[i j k] [x y z]]
  parseInput = input:
    let
      pairs = map (line: (map strings.toInt (splitStringWhitespace line))) (splitString "\n" input);
    in
    {
      col1 = (map (p: builtins.elemAt p 0) pairs);
      col2 = (map (p: builtins.elemAt p 1) pairs);
    };

  part1Answer =
    input:
    let
      p = parseInput input;
      sorted1 = lists.sort (p: q: p < q) p.col1;
      sorted2 = lists.sort (p: q: p < q) p.col2;
    in
    foldl' (acc: p: acc + (abs (p.fst - p.snd))) 0 (lists.zipLists sorted1 sorted2);

  part2Answer =
    input:
    let
      p = parseInput input;
      grouped1 = lists.groupBy toString p.col1;
      grouped2 = lists.groupBy toString p.col2;

      mathAttr = k: v: if grouped2 ? "${k}" then (toInt k) * (length v) * (length grouped2.${k}) else 0;
    in
    foldl' builtins.add 0 (attrsets.mapAttrsToList mathAttr grouped1);

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
