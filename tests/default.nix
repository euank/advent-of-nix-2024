{ nixpkgs, lib }:
with nixpkgs.lib;
with lib;
let

  assertHeap1Heap2Equal =
    h1: h2:
    if h1.size != h2.size then
      throw "size: ${toString h1.size} != ${toString h2.size}"
    else if h1.size == 0 then
      true
    else
      let
        h1' = lib.heap.pop h1;
        h2' = lib.heap2.pop h2;
      in
      if h1'.val != h2'.val then
        throw "val: ${toString h1'.val} != ${toString h2'.val}"
      else
        assertHeap1Heap2Equal h1'.heap h2'.heap;

  testHeap2 =
    let
      items = map toInt (splitString "\n" (fileContents ./heaptest-01));
    in
    assertHeap1Heap2Equal (foldl' (h: el: lib.heap.insert h el) (lib.heap.mkHeap (l: r: l - r)) items) (
      foldl' (h: el: (debug.traceValSeq (lib.heap2.insert h el))) (lib.heap2.mkHeap (l: r: l - r)) items
    );

in
{
  inherit testHeap2;
}
