{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      els = splitString "\n\n" input;
      parsePart =
        part:
        let
          grid = map stringToCharacters (splitString "\n" part);
          hashPoints = groupBy (el: toString el.x) (
            remove null (
              flatten (
                arr2.imap (
                  x: y: el:
                  if el == "#" then { inherit x y; } else null
                ) grid
              )
            )
          );
        in
        rec {
          isKey = all (el: el == ".") (head grid);
          v = builtins.genList (
            x: (if isKey then arrMin else arrMax) (map (el: el.y) hashPoints."${toString x}")
          ) (arr2.width grid);
        };
    in
    map parsePart els;

  overlaps = lock: key: any (l: l.snd <= l.fst) (zipLists lock key);

  # bruteforce part1
  part1Answer =
    input:
    let
      p = parseInput input;
      locks = map (el: el.v) (filter (el: !el.isKey) p);
      keys = map (el: el.v) (filter (el: el.isKey) p);
      pairs = cartesianProduct {
        l = locks;
        k = keys;
      };
    in
    length (concatMap (pair: if overlaps pair.l pair.k then [ ] else [ pair ]) pairs);

in
{
  part1 = part1Answer input;
}
