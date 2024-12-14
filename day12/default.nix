{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  findAreaPoints =
    grid: x: y:
    let
      c = arr2.get grid x y;
      subGrid = arr2.set grid x y null;
    in
    # already seen
    if c == null then
      {
        ans = [ ];
        grid = subGrid;
      }
    else
      force (
        foldl'
          (
            acc: el:
            (
              if (arr2.getDef acc.grid el.x el.y null) == c then
                let
                  s = findAreaPoints acc.grid el.x el.y;
                in
                {
                  grid = s.grid;
                  ans = acc.ans ++ s.ans;
                }
              else
                acc
            )
          )
          {
            ans = [ { inherit x y; } ];
            grid = subGrid;
          }
          [
            {
              x = x + 1;
              y = y;
            }
            {
              x = x - 1;
              y = y;
            }
            {
              x = x;
              y = y + 1;
            }
            {
              x = x;
              y = y - 1;
            }
          ]
      );

  parseInput =
    input:
    let
      grid = map stringToCharacters (splitString "\n" input);
      areas =
        (foldl'
          (
            acc: xy:
            let
              s = findAreaPoints acc.grid xy.x xy.y;
            in
            {
              grid = s.grid;
              ans = acc.ans ++ [ s.ans ];
            }
          )
          {
            ans = [ ];
            grid = grid;
          }
          (flatten (arr2.imap (x: y: _: { inherit x y; }) grid))
        ).ans;
    in
    {
      inherit grid areas;
    };

  squarePerim =
    grid: x: y:
    let
      c = arr2.get grid x y;
    in
    foldl' builtins.add 0 (
      map (adj: if (arr2.getDef grid adj.x adj.y null) == c then 0 else 1) [
        {
          x = x + 1;
          y = y;
        }
        {
          x = x - 1;
          y = y;
        }
        {
          x = x;
          y = y + 1;
        }
        {
          x = x;
          y = y - 1;
        }
      ]
    );

  calcScore =
    grid: el:
    let
      area = length el;
      perim = foldl' builtins.add 0 (map (el: squarePerim grid el.x el.y) el);
    in
    area * perim;

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    # p.areas;
    foldl' builtins.add 0 (map (el: (force calcScore p.grid el)) p.areas);

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
