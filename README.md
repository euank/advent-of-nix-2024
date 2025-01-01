## Advent of Nix 2024

This is my go at Advent of Code (2024) in pure nix.

### Running solutions

In general, `nix eval '.#dayX'` (where 'X' is the number of the day, padded to
length 2, such as `nix eval '.#day03'`) will display the answer to a given day.

Note, many solutions require increasing the max call depth and increasing the stack size.
For all solutions, consider running them as:

```
$ ulimit -s unlimited
$ nix eval --option max-call-depth 4294967295 ...
```

You also likely want to run parts one at a time, such as `nix eval
'.#day01.part2'` in order to reduce total resource usage; I only ever run them
like such, so some solutions may OOM if both parts are run together.

I'm also running this on a machine with 64GiB of memory, so solutions may take
up to that amount of memory.

I also have `experimental-features = ca-derivations dynamic-derivations flakes
nix-command recursive-nix` set in my `nix show-config`, though I think only
`flakes nix-command` are used in practice in this repo.

### Running solutions with tvix

If for some reason you want to see how slow tvix is on something, you can do that too:

```
$ time ./run-tvix.sh day06.part1

19.77s
max memory:                2879 MB

# as compared to nix
$ time nix eval --option max-call-depth 4294967295 '.#day06.part1'
3.07s
max memory:                2139 MB
```

In general tvix seems to be significantly slower, but it's interesting to compare!

Since `tvix` doesn't support `fetchGit` yet, `run-tvix` will populate a
'nixpkgs' symlink in the repository to use automatically.

This is done using `nix`, so you need nix installed as well.

### Day specific notes

#### Day 06

Part 2 takes an hour and 20GiB of memory to run on my machine.

I know there's a more optimal solution, but you know, it's fine.

#### Day 09

Both parts take around 12GiB of memory and 1.5 minutes.

#### Day 11

~10 minutes, but not much memory!

Thank gosh for `builtins.deepSeq` to avoid 60+ GiBs of thunks!

#### Day 12

Part1 is 5 minutes.

#### Day 16

Part 1 is ~5 minutes.

### Day 18

Part 1 took 37GiB of memory on my machine

### Day 20

Both parts take ~7.5 minutes (with 20GiB of memory usage).
