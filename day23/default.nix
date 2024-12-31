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

  triangles =
    tree: name: nodes:
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

  part1Answer =
    input:
    let
      p = parseInput input;
      tree = foldl' (acc: el: mergeAttrs acc (children 2 p el { })) { } (attrNames p);
      allAnswers = foldl' (
        acc: name:
        acc
        ++ (if strings.hasPrefix "t" name then triangles tree name (attrNames (tree."${name}")) else [ ])
      ) [ ] (attrNames tree);
    in
    length (unique allAnswers);

  # per google https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm
  bronkerbosch =
    tree: r: p: x:
    if (length (attrNames p)) == 0 && (length (attrNames x)) == 0 then
      (attrNames r)
    else
      (foldl'
        (
          acc: v:
          let
            res = bronkerbosch tree (r // { "${v}" = true; }) (intersectAttrs acc.p tree."${v}") (
              intersectAttrs acc.x tree."${v}"
            );
          in
          {
            res = if (length res) > (length acc.res) then res else acc.res;
            p = removeAttrs acc.p [ v ];
            x = acc.x // {
              "${v}" = true;
            };
          }
        )
        {
          inherit p x;
          res = [ ];
        }
        (attrNames p)
      ).res;

  part2Answer =
    input:
    let
      p = parseInput input;
      tree = foldl' (acc: el: mergeAttrs acc (children 2 p el { })) { } (attrNames p);
      set = bronkerbosch tree { } tree { };
    in
    concatStringsSep "," (naturalSort set);
in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
