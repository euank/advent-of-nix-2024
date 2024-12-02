{ nixpkgs, lib, ... }:
with nixpkgs.lib;
with lib;
let
  input = fileContents ./input;

  parseInput = input:
    map (line: map toInt (splitString " " line)) (splitString "\n" input);

  part1Answer = input:
    let
      p = parseInput input;
      isSafe = line:
        if (length line) <= 2 then
          true
        else
          let
            h = head line;
            n = head (tail line);
            nn = head (tail (tail line));
            # Increasing or decreasing
          in ((n > h && nn > n) || ((n < h) && nn < n))
          # Diff
          && ((abs (n - h)) <= 3) && ((abs (nn - n)) <= 3)
          # At least 1 diff
          && n != h && n != nn
          # And holds for the rest
          && isSafe (tail line);
    in foldl' (acc: line: acc + (if isSafe line then 1 else 0)) 0 p;

  part2Answer = input:
    let
      p = parseInput input;
      isSafe = line: hasSkipped:
        if (length line) <= 2 then
          true
        else
          let
            isSafeNoSkip = let
              h = head line;
              n = head (tail line);
              nn = head (tail (tail line));
              # Increasing or decreasing
            in ((n > h && nn > n) || ((n < h) && nn < n))
            # Diff
            && ((abs (n - h)) <= 3) && ((abs (nn - n)) <= 3)
            # At least 1 diff
            && n != h && n != nn
            # And holds for the rest
            && isSafe (tail line) hasSkipped;
          in isSafeNoSkip || (!hasSkipped && (
            # skip first
            (isSafe (tail line) true)
            # skip second
            || (isSafe ((take 1 line) ++ (drop 2 line)) true)));
    in foldl' (acc: line: acc + (if (isSafe line false) then 1 else 0)) 0 p;

in {
  part1 = part1Answer input;
  part2 = part2Answer input;
}
