{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input: map stringToCharacters (splitString "\n" input);

  part1Answer =
    input:
    let
      grid = parseInput input;
      countXmasFrom =
        x: y:
        let
          el = arr2.get grid x y;
          o3 = builtins.genList (i: i + 1) 3;
        in
        if el != "X" then
          0
        else
          # Check each direction
          let
            left = map (offset: arr2.getDef grid (x - offset) y "") o3;
            right = map (offset: arr2.getDef grid (x + offset) y "") o3;
            up = map (offset: arr2.getDef grid x (y - offset) "") o3;
            down = map (offset: arr2.getDef grid x (y + offset) "") o3;
            upleft = map (offset: arr2.getDef grid (x - offset) (y - offset) "") o3;
            upright = map (offset: arr2.getDef grid (x + offset) (y - offset) "") o3;
            downleft = map (offset: arr2.getDef grid (x - offset) (y + offset) "") o3;
            downright = map (offset: arr2.getDef grid (x + offset) (y + offset) "") o3;
          in
          foldl'
            (
              acc: dir:
              acc
              + (
                if
                  dir == [
                    "M"
                    "A"
                    "S"
                  ]
                then
                  1
                else
                  0
              )
            )
            0
            [
              left
              right
              up
              down
              upleft
              upright
              downleft
              downright
            ];
    in
    foldl' builtins.add 0 (
      flatten (
        arr2.imap (
          x: y: _:
          countXmasFrom x y
        ) grid
      )
    );

  part2Answer =
    input:
    let
      grid = parseInput input;
      countXmasFrom =
        x: y:
        let
          el = arr2.get grid x y;
        in
        if el != "A" then
          0
        else
          let
            upleft = arr2.getDef grid (x - 1) (y - 1) "";
            upright = arr2.getDef grid (x + 1) (y - 1) "";
            downleft = arr2.getDef grid (x - 1) (y + 1) "";
            downright = arr2.getDef grid (x + 1) (y + 1) "";
          in
          if
            (sort builtins.lessThan [
              upleft
              upright
              downleft
              downright
            ]) == [
              "M"
              "M"
              "S"
              "S"
            ]
            && upleft != downright
            && upright != downleft
          then
            1
          else
            0;
    in
    foldl' builtins.add 0 (
      flatten (
        arr2.imap (
          x: y: _:
          countXmasFrom x y
        ) grid
      )
    );

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
