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
    if goal == "" then
      {
        inherit memo;
        val = 1;
      }
    else if memo ? "${goal}" then
      {
        inherit memo;
        val = memo."${goal}";
      }
    else
      let
        childAnswer =
          foldl'
            (
              state: part:
              if strings.hasPrefix part goal then
                let
                  s = isPossible state.memo (removePrefix part goal) parts;
                in
                {
                  val = state.val + s.val;
                  memo = s.memo;
                }
              else
                state
            )
            {
              inherit memo;
              val = 0;
            }
            (attrNames parts);
      in
      rec {
        val = childAnswer.val;
        memo = childAnswer.memo // {
          "${goal}" = val;
        };
      };

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
          total = acc.total + (if s.val > 0 then 1 else 0);
        }
      )
      {
        memo = { };
        total = 0;
      }
      p.goals
    ).total;

  part2Answer =
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
          total = acc.total + s.val;
        }
      )
      {
        memo = { };
        total = 0;
      }
      p.goals
    ).total;
in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
