{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      lines = splitString "\n" input;
      a = toInt (elemAt (splitString ": " (elemAt lines 0)) 1);
      b = toInt (elemAt (splitString ": " (elemAt lines 1)) 1);
      c = toInt (elemAt (splitString ": " (elemAt lines 2)) 1);
      prog = map toInt (splitString "," (elemAt (splitString ": " (elemAt lines 4)) 1));
    in
    {
      inherit
        a
        b
        c
        prog
        ;
      ip = 0;
    };

  step =
    state:
    let
      inherit (state)
        a
        b
        c
        out
        ;
      instr = debug.traceValSeq (elemAt state.prog state.ip);
      operand = elemAt state.prog (state.ip + 1);
      ip = state.ip + 2;
      combo =
        op:
        if op <= 3 then
          op
        else if op == 4 then
          a
        else if op == 5 then
          b
        else if op == 6 then
          c
        else
          throw "${toString op}";
    in
    if state.ip >= (length state.prog) then
      state.out
    else if instr == 0 then
      force (
        step (
          state
          // {
            inherit ip;
            a = a / (pow 2 (combo operand));
          }
        )
      )
    else if instr == 1 then
      force (
        step (
          state
          // {
            inherit ip;
            b = builtins.bitXor b operand;
          }
        )
      )
    else if instr == 2 then
      force (
        step (
          state
          // {
            inherit ip;
            b = mod (combo operand) 8;
          }
        )
      )
    else if instr == 3 then
      force (step (state // (if a == 0 then { inherit ip; } else { ip = operand; })))
    else if instr == 4 then
      force (
        step (
          state
          // {
            inherit ip;
            b = builtins.bitXor b c;
          }
        )
      )
    else if instr == 5 then
      force (
        step (
          state
          // {
            inherit ip;
            b = builtins.bitXor b c;
            out = out ++ [ (mod (combo operand) 8) ];
          }
        )
      )
    else if instr == 6 then
      force (
        step (
          state
          // {
            inherit ip;
            b = a / (pow 2 (combo operand));
          }
        )
      )
    else if instr == 7 then
      force (
        step (
          state
          // {
            inherit ip;
            c = a / (pow 2 (debug.traceValSeq (combo operand)));
          }
        )
      )
    else
      throw "err";

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    concatMapStringsSep "," toString (step (p // { out = [ ]; }));
in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
