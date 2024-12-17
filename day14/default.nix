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
          x = toInt (el 0);
          y = toInt (el 1);
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
        x = trivial.mod (el.x + el.v.x * secs) w;
        y = trivial.mod (el.y + el.v.y * secs) h;
      };
    in
    {
      x = if r.x < 0 then w + r.x else r.x;
      y = if r.y < 0 then h + r.y else r.y;
      v = el.v;
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
    groupBy trivial.id (remove null (map (p: quad p.x p.y) points));

  part1Answer =
    input:
    let
      w = 101;
      h = 103;
      p = parseInput input;
      outPos = map (move 100 w h) p;
    in
    foldl' (acc: quad: acc * (length quad)) 1 (attrValues (scoreAnswers w h outPos));

  # I'm at a loss for what to do on part2, I don't know what the tree actually looks like.
  # But, well, part1 and part2 are usually related. Maybe a tree is centered
  # and has very few overlapping items, which would give it a very low score
  # (most items omitted by the center lines, etc).
  # ... Let's hope that works I guess.
  simPart2 =
    p: steps: minSoFar:
    if steps == 15000 then
      minSoFar
    else
      let
        d = foldl' (acc: quad: acc * (length quad)) 1 (attrValues (scoreAnswers 101 103 p));
      in
      simPart2 (map (move 1 101 103) p) (steps + 1) (
        if d < minSoFar.score then
          {
            score = d;
            step = steps;
          }
        else
          minSoFar
      );

  part2Answer =
    input:
    let
      p = parseInput input;
    in
    (simPart2 p 0 {
      score = 999999999;
      step = 0;
    }).step;

in
{
  part1 = part1Answer input;
  part2 = part2Answer input;
}
