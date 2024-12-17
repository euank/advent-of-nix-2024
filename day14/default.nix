{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput =
    input:
    let
      parts = splitString "\n" input;
      parsePart =
        part:
        let
          el = (elemAt (builtins.match "^p=([0-9]+),([0-9]+) v=([-0-9]+),([-0-9]+)$" part));
        in
        {
          p = {
            x = toInt (el 0);
            y = toInt (el 1);
          };
          v = {
            x = toInt (el 2);
            y = toInt (el 3);
          };
        };
    in
    map parsePart parts;

  move =
    secs: w: h: el:
    let
      r = {
        x = trivial.mod (el.p.x + el.v.x * secs) w;
        y = trivial.mod (el.p.y + el.v.y * secs) h;
      };
    in
    {
      x = if r.x < 0 then w + r.x else r.x;
      y = if r.y < 0 then h + r.y else r.y;
    };

  scoreAnswers =
    w: h: points:
    let
      quad =
        x: y:
        if x > (w / 2) && y > (h / 2) then
          "lr"
        else if x > (w / 2) && y < (h / 2) then
          "ur"
        else if x < (w / 2) && y < (h / 2) then
          "ul"
        else if x < (w / 2) && y > (h / 2) then
          "ll"
        else
          null;
    in
    attrValues (groupBy trivial.id (remove null (map (p: quad p.x p.y) points)));

  part1Answer =
    input:
    let
      w = 101;
      h = 103;
      p = parseInput input;
      outPos = map (move 100 w h) p;
    in
    foldl' (acc: quad: acc * (length quad)) 1 (scoreAnswers w h outPos);
in
{
  part1 = part1Answer input;
  #part2 = part2Answer input;
}
