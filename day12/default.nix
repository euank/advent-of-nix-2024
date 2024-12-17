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
    foldl' builtins.add 0 (map (el: (force calcScore p.grid el)) p.areas);

  squarePerim2 =
    grid: x: y:
    let
      xy = {
        inherit x y;
      };
      c = arr2.get grid x y;
    in
    foldl'
      (
        acc: el:
        acc
        ++ (
          if (arr2.getDef grid el.x el.y null) != c then
            [
              {
                x = xy.x;
                y = xy.y;
                side = el.side;
              }
            ]
          else
            [ ]
        )
      )
      [ ]
      [
        {
          x = xy.x + 1;
          y = xy.y;
          side = "right";
        }
        {
          x = xy.x - 1;
          y = xy.y;
          side = "left";
        }
        {
          x = xy.x;
          y = xy.y + 1;
          side = "down";
        }
        {
          x = xy.x;
          y = xy.y - 1;
          side = "up";
        }
      ];

  # segs are sorted already
  # The idea is that if we have '(0, 0), (0, 1), (0, 2), (0, 4)' that's two
  # disjoint segments, so two sides of the shape.
  # We run this for each direction independently, and call that good enough.
  numDisjointSegs =
    segs:
    let
      h = head segs;
      next = head (tail segs);
    in
    if length segs == 1 then
      1
    else
      (numDisjointSegs (tail segs))
      + (
        if (h.side == "right" || h.side == "left") && h.x == next.x && (next.y - h.y) == 1 then
          0
        else if h.y == next.y && (next.x - h.x) == 1 then
          0
        else
          1
      );

  perim2 =
    grid: points:
    let
      perimSegs = foldl' concat [ ] (map (el: force (squarePerim2 grid el.x el.y)) points);
      segs = attrValues (groupBy (el: el.side) perimSegs);
      segs' = map (
        el:
        sortOn (
          xy:
          if xy.side == "right" || xy.side == "left" then
            [
              xy.x
              xy.y
            ]
          else
            [
              xy.y
              xy.x
            ]
        ) el
      ) segs;
    in
    foldl' builtins.add 0 (map numDisjointSegs segs');

  calcScore2 =
    grid: points:
    let
      area = length points;
      per = perim2 grid points;
    in
    area * per;

  part2Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' builtins.add 0 (map (el: (force calcScore2 p.grid el)) p.areas);

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
