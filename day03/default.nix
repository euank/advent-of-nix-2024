{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  part1Answer =
    input:
    let
      pieces = splitString "mul(" input;
      parsePiece =
        s:
        let
          matches = builtins.match "^([0-9]+),([0-9]+)\\).*$" s;
        in
        if matches == null || (length matches) != 2 then
          0
        else
          foldl' (acc: p: acc * p) 1 (map toInt matches);
    in
    foldl' builtins.add 0 (map parsePiece pieces);

  part2Answer =
    input:
    let
      matches = builtins.split "mul\\(([0-9]+,[0-9]+)\\)|(do\\(\\))|(don't\\(\\))" input;
      instrs = remove null (flatten (map (e: if isList e then e else null) matches));
      step =
        state: instr:
        if instr == "do()" then
          state // { disabled = false; }
        else if instr == "don't()" then
          state // { disabled = true; }
        else if state.disabled then
          state
        else
          let
            parts = splitString "," instr;
          in
          state
          // {
            val = state.val + (foldl' builtins.mul 1 (map toInt parts));
          };
    in
    (foldl' step {
      val = 0;
      disabled = false;
    } instrs).val;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
