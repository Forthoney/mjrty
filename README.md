# mjrty
A verified implementation of the Boyer-Moore majority vote algorithm.
Given a finite sequence of items which contains a majority element,
the algorithm finds it in O(n) time and O(1) space.
If it doesn't contain a majority, it returns an arbitrary element.
In a rewindable sequence,
the programmer may perform a second pass through the sequence,
counting the occurences of the element to check if the returned element actually has a majority.

It only depends on equality checks (`DecidabelEq]`) meaning it also works for unhashable types.

## Usage
The repo contains a library with `List.mjrty` and `Std.Iter.mjrty`.
Additionally, it contains a simple executable which runs the algorithm over a file, 
using strings as elements.