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
              opStr = "${m 1}";
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

  binaryDigits =
    p: zs:
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

  part1Answer =
    input:
    let
      p = parseInput input;
      zs = filter (strings.hasPrefix "z") (attrNames p.instrs);
    in
    fromBinaryBits (binaryDigits p zs);

  doSwap =
    swap: state:
    state
    // {
      instrs = state.instrs // {
        "${swap.l}" = state.instrs."${swap.r}";
        "${swap.r}" = state.instrs."${swap.l}";
      };
    };

  pad2 = i: if i < 10 then "0${toString i}" else toString i;

  checkBit =
    p: zs: bit:
    let
      p' = {
        vals = listToAttrs (
          flatten (
            builtins.genList (i: [
              {
                name = "x${pad2 i}";
                value = if i == 0 then 1 else 0;
              }
              {
                name = "y${pad2 i}";
                value = if i == bit then 1 else 0;
              }
            ]) 45
          )
        );
        instrs = p.instrs;
      };
      expected = (pow 2 bit) + 1;
      actual = fromBinaryBits (binaryDigits p' zs);
    in
    actual == expected;

  findWrongBits =
    bit: p: zs:
    if bit > 44 then
      [ ]
    else
      (if !(checkBit p zs bit) then [ bit ] else [ ]) ++ (findWrongBits (bit + 1) p zs);

  # give us a way to sort left/right nodes in a tree of instructions
  # this is done hackily, but whatever.
  subtreeSum =
    node:
    if isString node then
      let
        prefix = head (stringToCharacters node);
        val = toIntBase10 (concatStrings (tail (stringToCharacters node)));
      in
      # I'm too lazy to make a proper ordering, so just pick big numbers to make x
      # < y generally, and then throw in the xor/and stuff to make it less likely
      # we tie.
      # I don't feel like I need to think about this too much unless it's a real
      # problem.
      if prefix == "x" then
        val + (pow 2 15)
      else if prefix == "y" then
        val + (pow 2 16)
      else if prefix == "z" then
        val + (pow 2 17)
      else
        throw "unknown prefix ${prefix}"
    else
      (subtreeSum node.l)
      + (subtreeSum node.r)
      + (
        if node.op == "AND" then
          pow 2 18
        else if node.op == "OR" then
          pow 2 19
        else
          0
      );

  isLess = nodeL: nodeR: (subtreeSum nodeL) < (subtreeSum nodeR);

  sortInstrTree =
    node:
    if isString node then
      node
    else
      node
      // {
        l = sortInstrTree (if isLess node.l node.r then node.l else node.r);
        r = sortInstrTree (if isLess node.l node.r then node.r else node.l);
      };

  getOperationsForVal =
    state: val:
    if state.vals ? "${val}" then
      val
    else
      let
        instr = state.instrs."${val}";
        lhs = getOperationsForVal state instr.l;
        rhs = getOperationsForVal state instr.r;
      in
      # order consistently so we can compare later
      sortInstrTree {
        l = lhs;
        r = rhs;
        op = instr.opStr;
        orig = val;
      };

  # equation for a carry bit in a ripple-carry adder
  carryBit =
    z:
    if z == 0 then
      throw 0
    else if z == 1 then
      {
        l = "x00";
        r = "y00";
        op = "AND";
      }
    else
      {
        l = {
          l = "x${pad2 (z - 1)}";
          r = "y${pad2 (z - 1)}";
          op = "AND";
        };
        op = "OR";
        r = {
          l = carryBit (z - 1);
          op = "AND";
          r = {
            l = "x${pad2 (z - 1)}";
            r = "y${pad2 (z - 1)}";
            op = "XOR";
          };
        };
      };

  # ripple-carry adder for an output bit, since that's what this is simulation,
  # we can make our own and then compare.
  expectedOperationsForBit =
    z:
    if z == 0 then
      {
        l = "x00";
        op = "XOR";
        r = "y00";
      }
    else
      sortInstrTree {
        l = {
          l = "x${pad2 z}";
          op = "XOR";
          r = "y${pad2 z}";
        };
        op = "XOR";
        r = carryBit z;
      };

  # findCorrect finds a single instruction that expands to the same "expected"
  # output we want right now, and returns it.
  # This tells us what to swap with.
  findCorrect =
    instrs: exp:
    let
      instr = findFirst (instr: isEqual instr exp) "?" instrs;
    in
    if isString instr then instr else instr.orig;

  # So this is a ripple carry adder, we can find what's wrong by basically
  # creating the expected output and diffing.
  # this function diffs the expected ripple-carry-adder I generated with the
  # actual input's one.
  findFirstMistake =
    instrs: exp: actual:
    # Ignore these first three types of mistakes, they don't show up in my
    # input thankfully.
    if (isString exp) && (isString actual) then
      null
    else if isString exp then
      null
    else if isString actual then
      null
    else if exp.op != actual.op then
      {
        l = actual.orig;
        r = findCorrect instrs exp;
      }
    else
      let
        l = findFirstMistake instrs exp.l actual.l;
      in
      if l != null then l else findFirstMistake instrs exp.r actual.r;

  part2Answer =
    input:
    let
      p = parseInput input;
      zs = filter (strings.hasPrefix "z") (attrNames p.instrs);

      # we know there's 4 swaps, the problem told us so, so try that.
      # assume that swapping to fix the lowest bit will always be good enough,
      # idk, it works for my input.
      ans = (
        foldl'
          (
            acc: _:
            let
              bit = head (findWrongBits 0 acc.state zs);
              fullInstrs = map (getOperationsForVal acc.state) (attrNames acc.state.instrs);
              actual = getOperationsForVal acc.state "z${pad2 bit}";
              swap = findFirstMistake fullInstrs (expectedOperationsForBit bit) actual;
            in
            {
              state = doSwap swap acc.state;
              swaps = acc.swaps ++ [ swap ];
            }
          )
          {
            swaps = [ ];
            state = p;
          }
          (builtins.genList trivial.id 4)
      );

      # verify it's good
      wrongBits = findWrongBits 0 ans.state zs;
    in
    if (length wrongBits) != 0 then
      throw "Wrong: ${builtins.toJSON wrongBits}"
    else
      concatStringsSep "," (
        naturalSort (
          concatMap (s: [
            s.l
            s.r
          ]) ans.swaps
        )
      );
in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
