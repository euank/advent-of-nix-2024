{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input: map stringToCharacters (splitString "\n" input);

  # I'm going to do a lot of this by hand because bleh, seems easiest.
  # Hardcode steps for getting between each pair of buttons in the top level
  # thing.
  # Note, we can omit a lot because we can do the inverse, i.e. A->0's inverse
  # is 0->A, and we can calculate that in a sec.
  # Note, at first I didn't realize order mattered, but after playing around,
  # it turns out under recursion, order does matter, and '<' should come first
  # when possible. Obviously repeating letters is optimal to minimize presses.
  baseNumpadMoves = {
    "A" = {
      "0" = "<";
      "1" = "^<<";
      "2" = "<^";
      "3" = "^";
      "4" = "^^<<";
      "5" = "<^^";
      "6" = "^^";
      "7" = "^^^<<";
      "8" = "<^^^";
      "9" = "^^^";
    };
    "0" = {
      "1" = "^<";
      "2" = "^";
      "3" = "^>";
      "4" = "^^<";
      "5" = "^^";
      "6" = "^^>";
      "7" = "^^^<";
      "8" = "^^^";
      "9" = "^^^>";
    };
    "1" = {
      "2" = ">";
      "3" = ">>";
      "4" = "^";
      "5" = "^>";
      "6" = "^>>";
      "7" = "^^";
      "8" = "^^>";
      "9" = "^^>>";
    };
    "2" = {
      "3" = ">";
      "4" = "<^";
      "5" = "^";
      "6" = "^>";
      "7" = "<^^";
      "8" = "^^";
      "9" = "^^>";
    };
    "3" = {
      "4" = "<<^";
      "5" = "<^";
      "6" = "^";
      "7" = "<<^^";
      "8" = "<^^";
      "9" = "^^";
    };
    "4" = {
      "5" = ">";
      "6" = ">>";
      "7" = "^";
      "8" = "^>";
      "9" = "^>>";
    };
    "5" = {
      "6" = ">";
      "7" = "<^";
      "8" = "^";
      "9" = "^>";
    };
    "6" = {
      "7" = "<<^";
      "8" = "<^";
      "9" = "^";
    };
    "7" = {
      "8" = ">";
      "9" = ">>";
    };
    "8" = {
      "9" = ">";
    };
    "9" = { };
  };

  expandMoves =
    base:
    let
      rev =
        c:
        {
          "^" = "v";
          "v" = "^";
          ">" = "<";
          "<" = ">";
        }
        .${c};
      buttons = attrNames base;
      c = mapAttrs' (
        k: v:
        nameValuePair k (
          mapAttrs' (k: v: {
            name = k;
            value = stringToCharacters v;
          }) v
        )
      ) base;
      # k here is somethign like "0", find all mappings by taking 0-> stuff + reverse mappings
      allVals =
        k:
        listToAttrs (
          map (b: {
            name = b;
            value =
              if k == b then
                [ ]
              else if c.${k} ? "${b}" then
                c.${k}.${b}
              else
                (map rev (reverseList c.${b}.${k}));
          }) buttons
        );
    in
    listToAttrs (
      map (k: {
        name = k;
        value = allVals k;
      }) buttons
    );

  allNumpadMoves = expandMoves baseNumpadMoves;

  keypadPath = expandMoves {
    "A" = {
      "^" = "<";
      ">" = "v";
      "v" = "<v";
      "<" = "v<<";
    };
    "^" = {
      ">" = "v>";
      "v" = "v";
      "<" = "v<";
    };
    ">" = {
      "v" = "<";
      "<" = "<<";
    };
    "v" = {
      "<" = "<";
    };
    "<" = { };
  };

  expand =
    seq:
    flatten (
      builtins.genList (idx: keypadPath.${elemAtDef seq (idx - 1) "A"}.${elemAt seq idx} ++ [ "A" ]) (
        length seq
      )
    );

  solve' =
    memo: seq: num:
    let
      seqPieces = splitString "A" (concatStrings (init seq));
    in
    if num == 0 then
      {
        inherit memo;
        res = length seq;
      }
    else
      foldl'
        (
          acc: piece:
          if acc.memo ? "${piece}-${toString num}" then
            {
              memo = acc.memo;
              res = acc.res + acc.memo."${piece}-${toString num}";
            }
          else
            let
              s = (solve' acc.memo (expand ((stringToCharacters piece) ++ [ "A" ]))) (num - 1);
            in
            {
              res = acc.res + s.res;
              memo = s.memo // {
                "${piece}-${toString num}" = s.res;
              };
            }
        )
        {
          inherit memo;
          res = 0;
        }
        seqPieces;

  solve =
    letters: num:
    let
      numPadMoves = flatten (
        builtins.genList (
          idx: allNumpadMoves.${elemAtDef letters (idx - 1) "A"}.${elemAt letters idx} ++ [ "A" ]
        ) (length letters)
      );
    in
    (solve' { } numPadMoves num).res;

  complexity = input: seq: (toIntBase10 (concatStrings (filter (el: el != "A") input))) * seq;

  part1Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' builtins.add 0 (map (line: complexity line (solve line 2)) p);

  part2Answer =
    input:
    let
      p = parseInput input;
    in
    foldl' builtins.add 0 (map (line: complexity line (solve line 25)) p);
in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
