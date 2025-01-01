# Expected output for `nix run '.#check'`
{ nixpkgs, lib }:

let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  answers = {
    "day01" = {
      part1 = 3714264;
      part2 = 18805872;
    };
    "day02" = {
      part1 = 257;
      part2 = 328;
    };
    "day03" = {
      part1 = 160672468;
      part2 = 84893551;
    };
    "day04" = {
      part1 = 2521;
      part2 = 1912;
    };
    "day05" = {
      part1 = 6949;
      part2 = 4145;
    };
    "day06" = {
      part1 = 4789;
      part2 = 1304;
    };
    "day07" = {
      part1 = 5030892084481;
      part2 = 91377448644679;
    };
    "day08" = {
      part1 = 318;
      part2 = 1126;
    };
    "day09" = {
      part1 = 6216544403458;
      part2 = 6237075041489;
    };
    "day10" = {
      part1 = 510;
      part2 = 1058;
    };
    "day11" = {
      part1 = 186424;
      part2 = 219838428124832;
    };
    "day12" = {
      part1 = 1370100;
      part2 = 818286;
    };
    "day13" = {
      part1 = 34393;
      part2 = 83551068361379;
    };
    "day14" = {
      part1 = 224438715;
      part2 = 7603;
    };
    "day15" = {
      part1 = 1457740;
      part2 = 1467145;
    };
    "day16" = {
      part1 = 105508;
      part2 = 548;
    };
    "day17" = {
      part1 = "7,0,3,1,2,6,3,7,1";
      part2 = 109020013201563;
    };
    "day18" = {
      part1 = 380;
      part2 = "26,50";
    };
    "day19" = {
      part1 = 213;
      part2 = 1016700771200474;
    };
    "day20" = {
      part1 = 1381;
      part2 = 982124;
    };
    "day21" = {
      part1 = 213536;
      part2 = 258369757013802;
    };
    "day22" = {
      part1 = 17724064040;
      part2 = 1998;
    };
    "day23" = {
      part1 = 1154;
      part2 = "aj,ds,gg,id,im,jx,kq,nj,ql,qr,ua,yh,zn";
    };
    "day24" = {
      part1 = 43559017878162;
      part2 = "fhc,ggt,hqk,mwh,qhj,z06,z11,z35";
    };
    "day25" = {
      part1 = 3395;
    };
  };

  checkDay =
    day:
    let
      answer = answers."${day}";
      actual = import ./${day} { inherit nixpkgs lib; };
    in
    if answer == actual then
      true
    else
      throw "${day} not equal; ${builtins.toJSON actual} != ${builtins.toJSON answer}";
in
{
  all = pkgs.writeShellScriptBin "check.sh" (
    pkgs.lib.strings.concatStringsSep "\n" (
      [ "set -x" ]
      ++ (pkgs.lib.attrsets.mapAttrsToList (
        day: _:
        "${pkgs.nix}/bin/nix eval --option max-call-depth 4294967295 '.#check.${day}' &>/dev/null && echo -e '\\033[0;32m${day} pass\\033[0m' || echo -e '\\033[0;31m${day} failed\\033[0m'"
      ) answers)
    )
  );
}
// (pkgs.lib.mapAttrs (day: _: checkDay day) answers)
