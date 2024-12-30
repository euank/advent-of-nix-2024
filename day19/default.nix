{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      parts = splitString "\n\n" input;
    in
    {
      parts = listToAttrs (
        map (k: {
          name = k;
          value = true;
        }) (splitString ", " (elemAt parts 0))
      );
      goals = splitString "\n" (elemAt parts 1);
    };

  isPossible =
    memo: goal: parts:
    if memo ? "${goal}" then
      {
        inherit memo;
        val = memo."${goal}";
      }
    else
      foldl'
        (
          state: part:
          if state.val then
            state
          else if strings.hasPrefix part goal then
            isPossible state.memo (removePrefix part goal) parts
          else
            state
        )
        {
          inherit memo;
          val = false;
        }
        (attrNames parts);

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    (foldl'
      (
        acc: el:
        let
          s = isPossible acc.memo el p.parts;
        in
        {
          memo = s.memo;
          total = acc.total + (if s.val then 1 else 0);
        }
      )
      {
        memo = p.parts;
        total = 0;
      }
      p.goals
    ).total;
in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
