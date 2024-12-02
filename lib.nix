{ pkgs }:
with pkgs.lib;
let
  lib = rec {
    splitStringWhitespace = s:
      flatten
      (builtins.filter builtins.isList (builtins.split "([^ ]+)" s));

    abs = num: if num < 0 then (-1) * num else num;
  };
in lib
