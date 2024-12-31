{ pkgs }:
with pkgs.lib;
let
  lib = rec {
    splitStringWhitespace = s: flatten (builtins.filter builtins.isList (builtins.split "([^ ]+)" s));

    abs = num: if num < 0 then (-1) * num else num;

    gcd = lhs: rhs: if lhs == 0 then rhs else gcd (trivial.mod rhs lhs) lhs;

    elemAtDef = arr: i: def: if i < 0 || i >= (length arr) then def else elemAt arr i;

    removeIdx = idx: arr: (sublist 0 idx arr) ++ (sublist (idx + 1) ((length arr) - 1) arr);
    setlist =
      n: val: arr:
      (sublist 0 n arr) ++ [ val ] ++ (sublist (n + 1) ((length arr) - 1) arr);

    # https://en.wikipedia.org/wiki/Exponentiation_by_squaring#Recursive_version
    # the naive recursive version was too slow for day 17
    pow =
      x: n:
      if n == 0 then
        1
      else if (mod n 2) == 0 then
        pow (x * x) (n / 2)
      else
        x * (pow (x * x) ((n - 1) / 2));

    force = x: builtins.deepSeq x x;
    forceShallow = x: builtins.seq x x;

    swap =
      arr: i: j:
      builtins.genList (
        idx:
        let
          idx' =
            if idx == i then
              j
            else if idx == j then
              i
            else
              idx;
        in
        builtins.elemAt arr idx'
      ) (builtins.length arr);

    heap2 = import ./heap2.nix { inherit pkgs lib; };
    heap = import ./heap.nix { inherit pkgs lib; };

    arr2 = rec {
      width = arr: if (length arr) == 0 then 0 else length (elemAt arr 0);
      height = length;

      get =
        arr: x: y:
        elemAt (elemAt arr y) x;

      set =
        arr: x: y: val:
        imap (
          x': y': el:
          if x == x' && y == y' then val else el
        ) arr;

      getDef =
        arr: x: y: def:
        if x < 0 || y < 0 then
          def
        else if x >= (width arr) || y >= (height arr) then
          def
        else
          elemAt (elemAt arr y) x;

      map = f: arr: genList (y: genList (x: f (get arr x y)) (length (head arr))) (length arr);
      imap = f: arr: genList (y: genList (x: f x y (get arr x y)) (length (head arr))) (length arr);

      swap =
        arr: x: y: x': y':
        let
          el = get arr x y;
          el' = get arr x' y';
        in
        imap (
          xx: yy: orig:
          if xx == x && yy == y then
            el'
          else if xx == x' && yy == y' then
            el
          else
            orig
        ) arr;

      findAll =
        arr: f:
        remove null (
          flatten (
            imap (
              x: y: el:
              if f el then { inherit x y; } else null
            ) arr
          )
        );
    };
  };
in
lib
