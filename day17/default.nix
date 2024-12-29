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
      instr = elemAt state.prog state.ip;
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
            c = a / (pow 2 (combo operand));
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

  # Let's manually run a couple rounds of our input:
  # Register A: 47719761
  # Register B: 0
  # Register C: 0
  # Program: 2,4,1,5,7,5,0,3,4,1,1,6,5,5,3,0
  #
  # while a > 0 {
  #   b = a % 8
  #   b = b ^ 5
  #   c = a / (2 ** b)
  #   a = a / 8
  #   b = b ^ c
  #   b = b ^ 6
  #   out(b % 8)
  # }
  #
  # Simplifying, and shuffling some stuff to octal for clarity, we get:
  #
  # for (a = ?; a > 0; a = a << 3) {
  # while a > 0 {
  #   b = (a % 0o1000) ^ 0o0101
  #   c = a / (2 ** b)
  #   out(((b ^ c) ^ (0o00110)) % 8)
  # }
  #
  # So basically, each loop we take a's lowest 3 bits (the mod), and xor them by a constant.
  # We then output a number based purely on a + those bits, and then take those bits off a.
  #
  # That means that the last digit output is based on a's last 3 bits only, and
  # as we step left, we can brute-force 3 bits at a time to figure things out I think.
  bruteForce =
    idx: state: a:
    let
      out = step (
        state
        // {
          out = [ ];
          inherit a;
        }
      );
    in
    # we multiplied by 8 when we found the last digit, knock that back off
    if idx == (length state.prog) then
      a / 8
    # multiply by 8 to start looking for the next 3 bits
    else if out == (sublist ((length state.prog) - idx - 1) (length state.prog) state.prog) then
      bruteForce (idx + 1) state (a * 8)
    else
      bruteForce idx state (a + 1);

  part2Answer =
    input:
    let
      state = parseInput input;
      a = bruteForce 0 state 0;
      out = step (
        state
        // {
          out = [ ];
          inherit a;
        }
      );
    in
    if out != state.prog then throw "${builtins.toJSON out} != ${builtins.toJSON state.prog}" else a;
in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
