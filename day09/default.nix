{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    imap0 (id: c: {
      id = id / 2;
      l = toInt c;
      free = (mod id 2) == 1;
    }) (stringToCharacters input);

  compact =
    chars:
    let
      h = debug.traceValSeq (head chars);
      l = last chars;
      chars' = init chars;
    in
    # done
    if (length chars) == 0 then
      [ ]
    # free stuff should be at the end, we can ignore it
    else if l.free then
      (compact chars')
    # not free stuff should be at the start, leave it there
    else if !h.free then
      [ h ] ++ (compact (tail chars))
    # if l.l == h.l, we can effectively replace h with l.
    else if l.l == h.l then
      [ l ] ++ (compact (tail chars'))
    # split
    else if l.l < h.l then
      [ l ]
      ++ (compact (
        [
          {
            inherit (h) free id;
            l = h.l - l.l;
          }
        ]
        ++ (tail chars')
      ))
    else if l.l > h.l then
      [
        {
          inherit (l) free id;
          l = h.l;
        }
      ]
      ++ (compact (
        (tail chars')
        ++ [
          {
            inherit (l) free id;
            l = l.l - h.l;
          }
        ]
      ))
    else
      throw "impossible";

  toKey = set: map (el: concatStrings (map toString (replicate el.l el.id))) set;

  compactNoStackOverflow =
    chars:
    builtins.genericClosure {
      startSet = [
        {
          chars = chars;
          key = toKey chars;
          ans = [ ];
        }
      ];
      operator =
        item:
        let
          chars = item.chars;
          h = debug.traceValSeq (head chars);
          l = last chars;
          chars' = init chars;
        in
        # done
        if (length chars) == 0 then
          [
            {
              key = item.key;
              ans = item.ans;
            }
          ]
        # free stuff should be at the end, we can ignore it
        else if l.free then
          [
            {
              key = toKey chars';
              chars = chars';
              inherit ans;
            }
          ]
        # not free stuff should be at the start, leave it there
        else if !h.free then
          [
            {
              ans = [ h ] ++ item.ans;
              key = toKey (tail chars);
              chars = tail chars;
            }
          ]
        # if l.l == h.l, we can effectively replace h with l.
        else if l.l == h.l then
          [
            {
              ans = [ l ] ++ item.ans;
              key = toKey (tail chars');
              chars = tail chars';
            }
          ]
        # split
        else if l.l < h.l then
          [
            rec {
              ans = [ l ] ++ item.ans;
              chars = [
                {
                  inherit (h) free id;
                  l = h.l - l.l;
                }
              ] ++ (tail chars');
              key = toKey chars;
            }
          ]
        else if l.l > h.l then
          [
            rec {
              ans = [
                {
                  inherit (l) free id;
                  l = h.l;
                }
              ] ++ item.ans;
              chars = (tail chars') ++ [
                {
                  inherit (l) free id;
                  l = l.l - h.l;
                }
              ];
              key = toKey chars;
            }
          ]
        else
          throw "impossible";
    };

  sumEl = i: el: foldl' builtins.add 0 (builtins.genList (idx: el.id * (i + idx)) el.l);

  part1Answer =
    input:
    let
      p = parseInput input;
      res = compactNoStackOverflow p;
    in
    (foldl'
      (acc: el: {
        val = acc.val + (sumEl acc.i el);
        i = acc.i + el.l;
      })
      {
        i = 0;
        val = 0;
      }
      res
    ).val;

in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
