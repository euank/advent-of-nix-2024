## Advent of Nix 2023

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

In order to be able to use `tvix`, which doesn't support `fetchGit` yet, the `nixpkgs` repo has been included as a submodule.

Before running `./run-tvix.sh`, please run `git submodule init && git submodule update`


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

Part1 is 5 minutes, and the default linux stack limit is too low. Try `ulimit -s unlimited`

#### Day 16

Part 1 is ~5 minutes.
