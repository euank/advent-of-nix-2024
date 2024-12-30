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
    else if next.x == 70 && next.y == 70 then
      next.dist
    else
      run (i + 1) (forceShallow (arr2.set visited next.x next.y next.dist)) (forceShallow heap') grid;

  solvePart1 =
    p: n:
    let
      grid = builtins.genList (_: builtins.genList (_: false) 71) 71;
      grid' = force (foldl' (g: el: arr2.set g el.x el.y true) grid (take n p));
      toVisit = lib.heap2.insert (lib.heap2.mkHeap (a: b: a.fdist - b.fdist)) {
        x = 0;
        y = 0;
        dist = 0;
        fdist = 140;
      };
      visited = arr2.map (_: null) grid;
    in
    run 0 visited toVisit grid';

  part1Answer = input: solvePart1 (parseInput input) 1024;

  part2Answer =
    input:
    let
      p = parseInput input;
      search =
        min: max:
        let
          n = (min + max) / 2;
          d = solvePart1 p n;
        in
        if min >= max || (min + 1) == max then
          let
            xy = elemAt p n;
          in
          "${toString xy.x},${toString xy.y}"
        else if d == null then
          force (search min n)
        else
          force (search n max);
    in
    search 1024 (length p);

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
