{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      grid = map stringToCharacters (splitString "\n" input);
      byChars = groupBy (el: el.c) (flatten (arr2.imap (x: y: c: { inherit x y c; }) grid));
    in
    {
      width = arr2.width grid;
      height = arr2.height grid;
      locs = removeAttrs byChars [ "." ];
    };

  antiNodes = l: r: [
    {
      x = l.x - (r.x - l.x);
      y = l.y - (r.y - l.y);
    }
    {
      x = r.x + (r.x - l.x);
      y = r.y + (r.y - l.y);
    }
  ];

  findAntinodes =
    charCoords:
    flatten (
      mapCartesianProduct ({ l, r }: if l == r then [ ] else antiNodes l r) {
        l = charCoords;
        r = charCoords;
      }
    );

  part1Answer =
    input:
    let
      p = parseInput input;
      ans = flatten (map findAntinodes (attrValues p.locs));
    in
    length (unique (filter ({ x, y }: x >= 0 && y >= 0 && x < p.width && y < p.height) ans));

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
