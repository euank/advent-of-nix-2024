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
      inherit grid start end;
    };

  dirToInt = dir: if dir.y == 0 then (dir.x + 1) / 2 else ((dir.y + 1) / 2) + 2;

  # Dijkstra's time
  part1Answer =
    input:
    let
      p = parseInput input;
      grid = p.grid;
      visited = arr2.map (_: [
        false
        false
        false
        false
      ]) grid;
      toVisit = lib.heap2.insert (lib.heap2.mkHeap (a: b: a.dist - b.dist)) (
        p.start
        // {
          dist = 0;
          dir = {
            x = 1;
            y = 0;
          };
        }
      );

      run =
        visited: toVisit: grid:
        let
          pop = force (lib.heap2.pop toVisit);
          heap = pop.heap;
          next = pop.val;
          dirInt = dirToInt next.dir;
          visitedVal = arr2.get visited next.x next.y;
          visitedDir = elemAt visitedVal dirInt;
          dirScores = [
            {
              score = 1;
              dir = next.dir;
            }
            {
              score = 1001;
              dir = {
                x = -1 * next.dir.y;
                y = next.dir.x;
              };
            }
            {
              score = 1001;
              dir = {
                x = next.dir.y;
                y = -1 * next.dir.x;
              };
            }
          ];
          heap' = force (
            foldl' (
              acc: el:
              if (arr2.get grid (next.x + el.dir.x) (next.y + el.dir.y)) != "#" then
                lib.heap2.insert acc {
                  x = next.x + el.dir.x;
                  y = next.y + el.dir.y;
                  dist = next.dist + el.score;
                  dir = el.dir;
                }
              else
                acc
            ) heap dirScores
          );
        in
        if next.x == p.end.x && next.y == p.end.y then
          next.dist
        else if visitedDir then
          # recurse again with the updated heap, i.e. skip this item
          run visited heap' grid
        else
          run (arr2.set visited next.x next.y (
            imap0 (i: el: if i == dirInt then true else el) visitedVal
          )) heap' grid;
    in
    run visited toVisit grid;

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
