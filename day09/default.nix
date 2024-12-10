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

  toKey = chars: map (el: concatStrings (map toString (replicate el.l el.id))) chars;

  compactNoStackOverflow =
    chars:
    builtins.genericClosure {
      startSet = [
        {
          inherit chars;
          key = toKey chars;
          ans = [ ];
        }
      ];
      operator =
        item:
        let
          chars = item.chars;
          h = head chars;
          l = last chars;
          chars' = init chars;
        in
        # done
        if (length chars) == 0 then
          [
            item
          ]
        # free stuff should be at the end, we can ignore it
        else if l.free then
          [
            {
              key = toKey chars';
              chars = chars';
              ans = item.ans;
            }
          ]
        # not free stuff should be at the start, leave it there
        else if !h.free then
          [
            {
              ans = item.ans ++ [ h ];
              key = toKey (tail chars);
              chars = tail chars;
            }
          ]
        # if l.l == h.l, we can effectively replace h with l.
        else if l.l == h.l then
          [
            {
              ans = item.ans ++ [ l ];
              key = toKey (tail chars');
              chars = tail chars';
            }
          ]
        # split
        else if l.l < h.l then
          [
            rec {
              ans = item.ans ++ [ l ];
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
              ans = item.ans ++ [
                {
                  inherit (l) free id;
                  l = h.l;
                }
              ];
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
      res = (last (compactNoStackOverflow p)).ans;
    in
    (foldl'
      (
        acc: el:
        if !el.free then
          {
            val = acc.val + (sumEl acc.i el);
            i = acc.i + el.l;
          }
        else
          acc
      )
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
