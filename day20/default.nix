{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      grid = map stringToCharacters (splitString "\n" input);
      start = head (
        remove null (
          flatten (
            arr2.imap (
              x: y: el:
              if el == "S" then { inherit x y; } else null
            ) grid
          )
        )
      );
      end = head (
        remove null (
          flatten (
            arr2.imap (
              x: y: el:
              if el == "E" then { inherit x y; } else null
            ) grid
          )
        )
      );
    in
    {
      inherit start end;
      grid = arr2.map (el: el == "#") grid;
    };

  # Dijkstra's time
  run =
    i: visited: toVisit: grid: end:
    let
      pop = lib.heap2.pop toVisit;
      heap = pop.heap;
      next = pop.val;
      heap' =
        foldl'
          (
            acc: el:
            let
              x = next.x + el.x;
              y = next.y + el.y;
              dist = next.dist + 1;
              fdist = next.dist + (abs (end.x - x)) + (abs (end.y - y));
              gridBlocked = arr2.getDef grid x y true;
              lastScore = arr2.getDef visited x y null;
            in
            if !gridBlocked && (lastScore == null || dist < lastScore) then
              forceShallow (
                lib.heap2.insert acc {
                  inherit
                    x
                    y
                    dist
                    fdist
                    ;
                }
              )
            else
              acc
          )
          heap
          [
            {
              x = 1;
              y = 0;
            }
            {
              x = -1;
              y = 0;
            }
            {
              y = 1;
              x = 0;
            }
            {
              y = -1;
              x = 0;
            }
          ];
    in
    if toVisit.size == 0 then
      null
    else if next.x == end.x && next.y == end.y then
      # done, return up all visited info
      arr2.set visited next.x next.y next.dist
    else
      run (i + 1) (forceShallow (arr2.set visited next.x next.y next.dist)) (forceShallow heap') grid end;

  ptDist = l: r: (abs (l.x - r.x)) + (abs (l.y - r.y));

  countImprovementsGreaterThan =
    dist: n: radius:
    let
      points = remove null (
        flatten (
          arr2.imap (
            x: y: dist:
            if dist == null then null else { inherit x y dist; }
          ) dist
        )
      );
      products = filter (el: el.l != el.r) (cartesianProduct {
        l = points;
        r = points;
      });
      withinRadius = filter (el: (ptDist el.l el.r) <= radius) products;
      greaterThan = filter (el: ((el.l.dist - el.r.dist) - (ptDist el.l el.r)) >= n) withinRadius;
    in
    length greaterThan;

  solve =
    p: radius:
    let
      toVisit = lib.heap2.insert (lib.heap2.mkHeap (a: b: a.dist - b.dist)) {
        x = p.start.x;
        y = p.start.y;
        dist = 0;
      };
      visited = arr2.set (arr2.map (_: null) p.grid) p.start.x p.start.y 0;
      res = run 0 visited toVisit p.grid p.end;
    in
    countImprovementsGreaterThan res 100 radius;

  part1Answer = input: solve (parseInput input) 2;
  part2Answer = input: solve (parseInput input) 20;
in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
