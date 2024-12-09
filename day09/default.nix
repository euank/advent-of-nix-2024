{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input: imap0 (id: c: { id = id / 2; l = toInt c; free = (mod id 2) == 1; }) (stringToCharacters input);

  compact = chars:
  let
    h = debug.traceValSeq (head chars);
    l = last chars;
    chars' = init chars;
  in
  # done
  if (length chars) == 0 then []
  # free stuff should be at the end, we can ignore it
  else if l.free then (compact chars')
  # not free stuff should be at the start, leave it there
  else if !h.free then [ h ] ++ (compact (tail chars))
  # if l.l == h.l, we can effectively replace h with l.
  else if l.l == h.l then [ l ] ++ (compact (tail chars'))
  # split
  else if l.l < h.l then [ l ] ++ (compact ([ { inherit (h) free id; l = h.l - l.l; }] ++ (tail chars')))
  else if l.l > h.l then [ { inherit (l) free id; l = h.l; } ] ++ (compact ((tail chars') ++ [ { inherit (l) free id; l = l.l - h.l; } ]))
  else throw "impossible";

  sumEl = i: el: foldl' builtins.add 0 (builtins.genList (idx: el.id * (i + idx)) el.l);

  part1Answer = input:
  let
    p = parseInput input;
    res = compact p;
  in
    (foldl' (acc: el: { val = acc.val + (sumEl acc.i el); i = acc.i + el.l; }) {i=0;val=0;} res).val;


in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
