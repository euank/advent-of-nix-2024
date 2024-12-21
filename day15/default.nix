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

  expandInput = state: {
    pos = {
      x = state.pos.x * 2;
      y = state.pos.y;
    };
    moves = state.moves;
    grid = map (line: stringToCharacters (concatStrings line)) (
      arr2.map (
        el:
        if el == "." then
          ".."
        else if el == "#" then
          "##"
        else if el == "O" then
          "[]"
        else
          throw el
      ) state.grid
    );
  };

  sortMoves =
    dir: moves:
    let
      moves' = unique (map (xyxy: sortOn (xy: if dir.x == 0 then xy.y else xy.x) xyxy) moves);
    in
    if dir.x == -1 then
      sortOn (xyxy: (head xyxy).x) moves'
    else if dir.x == 1 then
      reverseList (sortOn (xyxy: (head xyxy).x) moves')
    else if dir.y == -1 then
      sortOn (xyxy: (head xyxy).y) moves'
    else
      reverseList (sortOn (xyxy: (head xyxy).y) moves');

  step2 =
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
        in
        if el == "." then
          # done, we swap into place
          [
            [
              nextPos
              pos
            ]
          ]
        else if el == "#" then
          # Done, we're stuck
          [ ]
        else if (el == "]" || el == "[") && diff.x != 0 then
          # right or left, that means no need to recurse twice, just go once and move ourselves
          let
            rm = posChanges nextPos diff;
          in
          if (length rm) == 0 then
            rm
          else
            [
              [
                pos
                nextPos
              ]
            ]
            ++ rm
        else if (el == "[" || el == "]") && diff.y != 0 then
          # up/down case we need to branch for both box halves
          let
            u1 = posChanges nextPos diff;
            u2 = posChanges {
              x = nextPos.x + (if el == "]" then -1 else 1);
              y = nextPos.y;
            } diff;
          in
          if (length u1) == 0 || (length u2) == 0 then
            [ ]
          else
            u1
            ++ u2
            ++ [
              [
                nextPos
                pos
              ]
            ]
        else
          throw el;
      pChanges = sortMoves nextStep (posChanges pos nextStep);
    in
    if (length state.moves) == 0 then
      state
    else
      force (step2 {
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
      });

  calcScore2 =
    grid:
    foldl' builtins.add 0 (
      flatten (
        arr2.imap (
          x: y: el:
          if el == "[" then 100 * y + x else 0
        ) grid
      )
    );

  part2Answer =
    input:
    let
      p = expandInput (parseInput input);
    in
    calcScore2 (step2 p).grid;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
