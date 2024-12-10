{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    arr2.map (v: if v == "." then 99 else toInt v) (map stringToCharacters (splitString "\n" input));

  numReachableFrom =
    grid: x: y: prevX: prevY:
    let
      v = arr2.get grid x y;

      step1 =
        nextX: nextY:
        let
          v' = arr2.getDef grid nextX nextY 12;
        in
        if nextX == prevX && nextY == prevY then
          [ ]
        else if v' == (v + 1) then
          numReachableFrom grid nextX nextY x y
        else
          [ ];
    in
    if v == 9 then
      [ { inherit x y; } ]
    else
      foldl' (acc: el: acc ++ (step1 (x + el.x) (y + el.y))) [ ] [
        {
          x = -1;
          y = 0;
        }
        {
          x = 1;
          y = 0;
        }
        {
          x = 0;
          y = 1;
        }
        {
          x = 0;
          y = -1;
        }
      ];

  part1Answer =
    input:
    let
      p = parseInput input;
      startPoints = remove null (
        flatten (
          arr2.imap (
            x: y: el:
            if el == 0 then { inherit x y; } else null
          ) p
        )
      );
    in
    foldl' (
      acc: start:
      let
        res = length (unique (numReachableFrom p start.x start.y (-20) (-20)));
      in
      acc + res
    ) 0 startPoints;

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
