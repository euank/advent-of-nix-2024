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

  dirs = [
    {
      x = 1;
      y = 0;
    }
    {
      x = -1;
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

  countImprovementsGreaterThan =
    grid: dist: n:
    foldl' builtins.add 0 (
      flatten (
        arr2.imap (
          x: y: el:
          if el == null then
            0
          else
            # try each direction
            foldl' builtins.add 0 (
              map (
                dir:
                let
                  isBlocked = arr2.getDef grid (x + dir.x) (y + dir.y) false;
                  el'' = arr2.getDef dist (x + dir.x * 2) (y + dir.y * 2) null;
                in
                if isBlocked && el'' != null && (el'' - el) > n then 1 else 0
              ) dirs
            )
        ) dist
      )
    );

  solvePart1 =
    p:
    let
      toVisit = lib.heap2.insert (lib.heap2.mkHeap (a: b: a.fdist - b.fdist)) {
        x = p.start.x;
        y = p.start.y;
        dist = 0;
        fdist = (abs (p.start.x - p.end.x)) + (abs (p.start.y - p.end.y));
      };
      visited = arr2.map (_: null) p.grid;
      res = run 0 visited toVisit p.grid p.end;
    in
    countImprovementsGreaterThan p.grid res 100;

  part1Answer = input: solvePart1 (parseInput input);

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
