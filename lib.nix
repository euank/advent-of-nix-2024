{ pkgs }:
with pkgs.lib;
let
  lib = {
    splitStringWhitespace = s: flatten (builtins.filter builtins.isList (builtins.split "([^ ]+)" s));

    abs = num: if num < 0 then (-1) * num else num;

    removeIdx = idx: arr: (sublist 0 idx arr) ++ (sublist (idx + 1) ((length arr) - 1) arr);

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

    arr2 = rec {
      width = arr: if (length arr) == 0 then 0 else length (elemAt arr 0);
      height = length;

      get =
        arr: x: y:
        elemAt (elemAt arr y) x;

      getDef =
        arr: x: y: def:
        if x < 0 || y < 0 then
          def
        else if x >= (width arr) || y >= (height arr) then
          def
        else
          elemAt (elemAt arr y) x;

      imap = f: arr: genList (y: genList (x: f x y (get arr x y)) (length (head arr))) (length arr);

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
