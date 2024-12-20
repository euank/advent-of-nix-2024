{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      parts = splitString "\n\n" input;
      grid' = map stringToCharacters (splitString "\n" (elemAt parts 0));
      moves = remove "\n" (stringToCharacters (elemAt parts 1));
      pos = head (
        remove null (
          flatten (
            arr2.imap (
              x: y: el:
              if el == "@" then { inherit x y; } else null
            ) grid'
          )
        )
      );
      grid = arr2.map (el: if el == "@" then "." else el) grid';
    in
    {
      inherit grid moves pos;
    };

  # changes is an array like:
  # [ (0, 1) (0, 2) ] [ (0, 2) (0, 3) ]
  # indicating which elements get moved where. The first is where it's moved
  # to, the second is what's moved.
  applyPosChanges =
    changes: grid:
    if (length changes) == 0 then
      grid
    else
      let
        c = head changes;
        next = elemAt c 0;
        cur = elemAt c 1;
      in
      applyPosChanges (tail changes) (arr2.swap grid next.x next.y cur.x cur.y);

  step =
    state:
    let
      move = head state.moves;
      pos = state.pos;
      nextStep = {
        x =
          {
            ">" = 1;
            "<" = -1;
            "^" = 0;
            "v" = 0;
          }
          .${move};
        y =
          {
            ">" = 0;
            "<" = 0;
            "^" = -1;
            "v" = 1;
          }
          .${move};
      };
      posChanges =
        pos: diff:
        let
          nextPos = {
            x = pos.x + diff.x;
            y = pos.y + diff.y;
          };
          el = arr2.get state.grid nextPos.x nextPos.y;
          subMoves = posChanges nextPos diff;
        in
        if el == "#" then
          [ ]
        else if el == "O" && (length subMoves) > 0 then
          subMoves
          ++ [
            [
              nextPos
              pos
            ]
          ]
        else if el == "O" then
          [ ]
        else
          [
            [
              nextPos
              pos
            ]
          ];
      pChanges = posChanges pos nextStep;
    in
    if (length state.moves) == 0 then
      state
    else
      step {
        moves = tail state.moves;
        grid = applyPosChanges pChanges state.grid;
        pos =
          if (length pChanges) > 0 then
            {
              x = pos.x + nextStep.x;
              y = pos.y + nextStep.y;
            }
          else
            pos;
      };

  calcScore =
    grid:
    foldl' builtins.add 0 (
      flatten (
        arr2.imap (
          x: y: el:
          if el == "O" then 100 * y + x else 0
        ) grid
      )
    );

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    calcScore (step p).grid;

in
{
  part1 = part1Answer input;
  #  part2 = part2Answer input;
}
