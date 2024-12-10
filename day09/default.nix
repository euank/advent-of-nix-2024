{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    imap0 (id': c: rec {
      l = toInt c;
      free = (mod id' 2) == 1;
      id = if free then "." else id' / 2;
    }) (stringToCharacters input);

  toKey = chars: concatStrings (map (el: concatStrings (map toString (replicate el.l el.id))) chars);

  compactNoStackOverflow =
    chars:
    builtins.genericClosure {
      startSet = [
        {
          inherit chars;
          key = 0;
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
              key = item.key + 1;
              chars = chars';
              ans = item.ans;
            }
          ]
        # not free stuff should be at the start, leave it there
        else if !h.free then
          [
            {
              ans = item.ans ++ [ h ];
              key = item.key + 1;
              chars = tail chars;
            }
          ]
        # if l.l == h.l, we can effectively replace h with l.
        else if l.l == h.l then
          [
            {
              ans = item.ans ++ [ l ];
              key = item.key + 1;
              chars = tail chars';
            }
          ]
        # split
        else if l.l < h.l then
          [
            {
              ans = item.ans ++ [ l ];
              chars = [
                {
                  inherit (h) free id;
                  l = h.l - l.l;
                }
              ] ++ (tail chars');
              key = item.key + 1;
            }
          ]
        else if l.l > h.l then
          [
            {
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
              key = item.key + 1;
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

  compactNoStackOverflow2 =
    chars:
    builtins.genericClosure {
      startSet = [
        {
          inherit chars;
          ans = [ ];
          key = 0;
        }
      ];
      operator =
        item:
        let
          chars = item.chars;
          l = last chars;
          fitsIdx = (lists.findFirstIndex (el: el.free && el.l >= l.l) null chars);
          fitsEl = elemAt chars fitsIdx;
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
              ans = [ l ] ++ item.ans;
              chars = init item.chars;
              key = item.key + 1;
            }
          ]
        # Can't fit anything don't move it
        else if fitsIdx == null then
          [
            {
              ans = [ l ] ++ item.ans;
              chars = init item.chars;
              key = item.key + 1;
            }
          ]
        else if fitsEl.l == l.l then
          [
            {
              ans = [ fitsEl ] ++ item.ans;
              chars = setlist fitsIdx l (init item.chars);
              key = item.key + 1;
            }
          ]
        # split
        else if fitsEl.l > l.l then
          [
            {
              ans = [
                {
                  free = true;
                  id = ".";
                  l = l.l;
                }
              ] ++ item.ans;
              chars = flatten (
                setlist fitsIdx [
                  l
                  {
                    free = true;
                    id = ".";
                    l = fitsEl.l - l.l;
                  }
                ] (init item.chars)
              );
              key = item.key + 1;
            }
          ]
        # leave this blank in place
        else
          [
            {
              ans = [ l ] ++ item.ans;
              chars = init item.chars;
              key = item.key + 1;
            }
          ];
    };

  part2Answer =
    input:
    let
      p = parseInput input;
      res = (last (compactNoStackOverflow2 p)).ans;
    in
    (foldl'
      (acc: el: {
        val = acc.val + (if !el.free then sumEl acc.i el else 0);
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
  part2 = part2Answer input;
}
