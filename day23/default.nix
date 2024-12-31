{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      lines = splitString "\n" input;
      conns = map (
        line:
        let
          ea = elemAt (splitString "-" line);
        in
        {
          "${ea 0}" = ea 1;
          "${ea 1}" = ea 0;
        }
      ) lines;
    in
    zipAttrsWith (n: vals: vals) conns;

  children =
    depth: p: node: used:
    if depth == 0 then
      { }
    else
      listToAttrs (
        concatMap (
          child:
          if used ? "${child}" then
            [ ]
          else
            [
              {
                name = child;
                value = children (depth - 1) p child (used // { "${child}" = true; });
              }
            ]
        ) p."${node}"
      );

  part1Answer =
    input:
    let
      p = parseInput input;
      tree = foldl' (acc: el: mergeAttrs acc (children 2 p el { })) { } (attrNames p);

      valPairsConnectingTo =
        name: nodes:
        let
          pairs = filter (a: a.l != a.r) (cartesianProduct {
            l = nodes;
            r = nodes;
          });
        in
        foldl' (
          acc: el:
          acc
          ++ (
            if
              (all trivial.id [
                (tree."${el.l}" ? "${name}")
                (tree."${el.r}" ? "${name}")
                (tree."${el.l}" ? "${el.r}")
                (tree."${el.r}" ? "${el.l}")
              ])
            then
              [
                (naturalSort [
                  el.l
                  el.r
                  name
                ])
              ]
            else
              [ ]
          )
        ) [ ] pairs;

      allAnswers = foldl' (
        acc: name:
        acc
        ++ (
          if strings.hasPrefix "t" name then valPairsConnectingTo name (attrNames (tree."${name}")) else [ ]
        )
      ) [ ] (attrNames tree);
    in
    length (unique allAnswers);
in
{
  part1 = part1Answer input;
  # part2 = part2Answer input;
}
