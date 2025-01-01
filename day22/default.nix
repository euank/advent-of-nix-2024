{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input: map toInt (splitString "\n" input);

  prune = n: mod n 16777216;
  mix = a: b: builtins.bitXor a b;

  step =
    num:
    let
      i1 = prune (mix num (num * 64));
      i2 = prune (mix i1 (i1 / 32));
      i3 = prune (mix i2 (i2 * 2048));
    in
    i3;

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' builtins.add 0 (map (n: foldl' (acc: el: step acc) n (builtins.genList trivial.id 2000)) p);

  seqVals =
    seq: res:
    if (length seq) < 5 then
      res
    else
      let
        seq' = concatStringsSep "," (
          map toString (builtins.genList (i: (elemAt seq (i + 1)) - (elemAt seq i)) 4)
        );
      in
      if res ? "${seq'}" then
        seqVals (tail seq) res
      else
        (seqVals (tail seq) (forceShallow (res // { "${seq'}" = elemAt seq 4; })));

  findBest =
    seqs:
    let
      maps = map (s: force (seqVals s { })) seqs;
      merged = zipAttrsWith (name: values: foldl' builtins.add 0 values) maps;
    in
    foldl' (m: el: if el.value > m.value then el else m) {
      name = "";
      value = 0;
    } (attrsToList merged);

  part2Answer =
    input:
    let
      p = parseInput input;
      seqs = map (
        n:
        (foldl'
          (
            acc: _:
            let
              n' = step acc.n;
            in
            {
              n = n';
              seq = acc.seq ++ [ (mod n' 10) ];
            }
          )
          {
            seq = [ (mod n 10) ];
            n = n;
          }
          (builtins.genList trivial.id 2000)
        ).seq
      ) p;
    in
    (findBest seqs).value;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
