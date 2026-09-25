# Power Cut

Difficulty: easy. Time limit: 1 second.

## Problem Summary

A storm has knocked out the main power line to campus. The campus map is a grid with R rows and C columns, where each cell is one of:

- '#' a wall
- '.' an open corridor
- 'L' a computer lab
- 'G' a working backup generator

Power travels from a generator through any cells that are not walls, moving up, down, left or right (never diagonally). A lab has power if it is connected to at least one generator this way.

The admin office can buy portable generators and place each one on any cell that is not a wall. What is the minimum number of portable generators needed so that every lab has power?

### Input

The first line contains two integers R and C (1 ≤ R, C ≤ 25).

The next R lines each contain a string of exactly C characters, each one of #, ., L or G.

### Output

Print a single integer: the minimum number of portable generators needed.

### Examples

**Sample input 1**

```
5 7
L..#.L#
##.###.
G..#L#.
...#..#
####...

```

**Sample output 1**

```
2
```

**Explanation:** The lab in the top-left corner already has power. The other three labs have no connection to any generator. Two well-placed portable generators are enough to power all three of them, but one is not.

**Sample input 2**

```
2 3
L#G
.#.

```

**Sample output 2**

```
1
```

**Explanation:** The wall column cuts the lab off from the generator, so one portable generator is needed.
