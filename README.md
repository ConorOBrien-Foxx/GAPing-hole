# memGAP

memGAP is a language designed to be odd to work in. A surprise, I know.

## How to write a program

Programs consists of md5 hashes, which are then brute forced to return individual commands. The following commands are available at your disposal:

* `size` - pops `S`; pushes the size of `S`.
* `add` - pops `B` then `A`; pushes `A + B`.
* `neg` - pops `N`; pushes `-N`.
* `rep` - pops `N`; pushes `"1"` repeated `N` times.
* `swap` - swaps the top two members of the stack.
* `bub` - pops `N`; rotates the top `N` members once to the left. (e.g. `1 2 3 4   4 bub` becomes `2 3 4 1`)
* `char` - pops `N`; pushes the character with charcode `N`.
* `out` - pops `X`; prints `X`.
* `dup` - duplicates the top element on the stack.
* `pop` - pops the top element of the stack.
* `nil` - pushes `0`.
* `len` - pushes the number of elements in the stack.
* `open` - starts a loop while the top element is neither 0 nor the empty string.
* `shut` - closes that loop.
* `?` - used for debugging in the program.
* `in` - pushes a string from STDIN
* `#` - inputs a number
* `btwn` - pops `U` then `L` then `N`; pushes `L <= N <= U`.
* `get` - pops `N` then `A`; pushes `A`, then pushes `A[n]`.

All other commands are pushed verbatim to the stack.