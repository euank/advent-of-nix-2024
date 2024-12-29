{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      lines = splitString "\n" input;
    in
    map (
      line:
      let
        a = map toInt (splitString "," line);
      in
      {
        x = head a;
        y = last a;
      }
    ) lines;

  part1Answer =
    input:
    let
      p = parseInput input;
      # make a grid with 'false' for open, 'true' for blocked
      grid = builtins.genList (_: builtins.genList (_: false) 71) 71;
      grid' = force (foldl' (g: el: arr2.set g el.x el.y true) grid (take 1024 p));
      toVisit = lib.heap2.insert (lib.heap2.mkHeap (a: b: a.fdist - b.fdist)) {
        x = 0;
        y = 0;
        dist = 0;
        fdist = 140;
      };
      visited = arr2.map (_: null) grid;

      # Dijkstra's time
      run =
        i: visited: toVisit: grid:
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
                  fdist = next.dist + (70 - x) + (70 - y);
                  gridBlocked = arr2.getDef grid x y true;
                  lastScore = arr2.getDef visited x y null;
                in
                if !gridBlocked && (lastScore == null || dist < lastScore) then
                  lib.heap2.insert acc {
                    inherit
                      x
                      y
                      dist
                      fdist
                      ;
                  }
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
        if next.x == 70 && next.y == 70 then
          next.dist
        else
          run (i + 1) (forceShallow (arr2.set visited next.x next.y next.dist)) (forceShallow heap') grid;
    in
    run 0 visited toVisit grid';

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
