{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  toKey = xy: "${toString xy.x}.${toString xy.y}";

  parseInput =
    input:
    let
      grid = map stringToCharacters (splitString "\n" input);
    in
    {
      guard = head (arr2.findAll grid (el: el == "^"));
      dir = {
        x = 0;
        y = -1;
      };
      # We could make a lookup of like 'byX = [ [y=1 y=3 ] ... ]' to make this
      # much faster, but for now, see if a hashmap and step-by-step is fast
      # enough.
      blocks = foldl' (acc: xy: acc // { "${toKey xy}" = true; }) { } (arr2.findAll grid (el: el == "#"));
      width = arr2.width grid;
      height = arr2.height grid;
    };

  stepDir = dir: {
    x = -1 * dir.y;
    y = dir.x;
  };

  updateSeen =
    seen: guard: dir:
    recursiveUpdate seen {
      "${toKey guard}" = {
        "${toKey dir}" = true;
      };
    };

  step =
    board: seen:
    if
      board.guard.x < 0
      || board.guard.y < 0
      || board.guard.x >= board.width
      || board.guard.y >= board.height
    then
      seen
    # loop
    else if
      hasAttrByPath [
        (toKey board.guard)
        (toKey board.dir)
      ] seen
    then
      null
    else
      let
        nextStep = {
          x = board.guard.x + board.dir.x;
          y = board.guard.y + board.dir.y;
        };
      in
      if board.blocks ? "${toKey nextStep}" then
        step (board // { dir = stepDir board.dir; }) seen
      else
        step (board // { guard = nextStep; }) (updateSeen seen board.guard board.dir);

  part1Answer =
    input:
    let
      board = parseInput input;
    in
    length (builtins.attrNames (step board { }));

  # For part1, we only had a few thousand places the guard actually stepped,
  # this seems very brute-forceable!
  # Runtime was like 200ms before, so if we simulate 5000 locations, we expect under 30 minute runtime, seems fine!
  part2Answer =
    input:
    let
      board = parseInput input;
      steps = builtins.attrNames (step board { });
    in
    foldl' (
      acc: xy:
      if
        (step (
          board
          // {
            blocks = board.blocks // {
              "${xy}" = true;
            };
          }
        ) { }) == null
      then
        acc + 1
      else
        acc
    ) 0 steps;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
