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

  valid =
    an: w: h:
    an.x >= 0 && an.y >= 0 && an.x < w && an.y < h;

  part1Answer =
    input:
    let
      p = parseInput input;
      ans = flatten (map findAntinodes (attrValues p.locs));
    in
    length (unique (filter (an: valid an p.width p.height) ans));

  antiNodesL =
    l: r: w: h:
    let
      nl = {
        x = l.x - (r.x - l.x);
        y = l.y - (r.y - l.y);
      };
    in
    if valid nl w h then [ nl ] ++ (antiNodesL nl l w h) else [ ];

  antiNodesR =
    l: r: w: h:
    let
      nr = {
        x = r.x + (r.x - l.x);
        y = r.y + (r.y - l.y);
      };
    in
    if valid nr w h then [ nr ] ++ (antiNodesR r nr w h) else [ ];

  antiNodes2 =
    l: r: w: h:
    [
      { inherit (l) x y; }
      { inherit (r) x y; }
    ]
    ++ (antiNodesL r l w h)
    ++ (antiNodesR l r w h);

  findAntinodes2 =
    width: height: charCoords:
    flatten (
      mapCartesianProduct ({ l, r }: if l == r then [ ] else antiNodes2 l r width height) {
        l = charCoords;
        r = charCoords;
      }
    );

  part2Answer =
    input:
    let
      p = parseInput input;
      ans = flatten (map (v: findAntinodes2 p.width p.height v) (attrValues p.locs));
    in
    length (unique ans);

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
