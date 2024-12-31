{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      parts = splitString "\n\n" input;
      wires = listToAttrs (
        map (
          el:
          let
            tmp = elemAt (splitString ": " el);
          in
          {
            name = tmp 0;
            value = toInt (tmp 1);
          }
        ) (splitString "\n" (elemAt parts 0))
      );

      instrs = listToAttrs (
        map (
          line:
          let
            m = elemAt (builtins.match "^([^ ]+) (AND|OR|XOR) ([^ ]+) -> (.*)$" line);
          in
          {
            name = m 3;
            value = {
              l = m 0;
              r = m 2;
              op =
                {
                  AND = bitAnd;
                  OR = bitOr;
                  XOR = bitXor;
                }
                ."${m 1}";
            };
          }
        ) (splitString "\n" (elemAt parts 1))
      );
    in
    {
      vals = wires;
      inherit instrs;
    };

  solveVal =
    state: val:
    if state.vals ? "${val}" then
      {
        inherit state;
        val = state.vals."${val}";
      }
    else
      let
        instr = state.instrs."${val}";
        lhs = solveVal state instr.l;
        rhs = solveVal lhs.state instr.r;
        state' = rhs.state;
        val' = instr.op lhs.val rhs.val;
      in
      {
        state = state' // {
          "${val}" = val';
        };
        val = val';
      };

  part1Answer =
    input:
    let
      p = parseInput input;
      zs = filter (strings.hasPrefix "z") (attrNames p.instrs);
    in
    fromBinaryBits
      (foldl'
        (
          state: var:
          let
            s = solveVal state.state var;
          in
          {
            state = s.state;
            out = [ s.val ] ++ state.out;
          }
        )
        {
          state = p;
          out = [ ];
        }
        zs
      ).out;

in
{
  part1 = part1Answer input;
  #part2 = part2Answer input;
}
