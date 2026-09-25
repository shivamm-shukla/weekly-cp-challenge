# Hackathon Leaderboard

Difficulty: medium. Time limit: 1 second.

## Problem Summary

The Sitare hackathon had n teams, numbered 1 to n. The judges lost the final scoresheet. All they have left are m scribbled notes, each saying “team a finished above team b."
The organisers want to reconstruct the leaderboard: a full ranking of all n teams, with no ties, that agrees with every note. They need to know which of these is true:

- the notes contradict each other, so no ranking is possible;
- exactly one ranking fits the notes;
- more than one ranking fits the notes.

### Input

The first line contains two integers n and m (1 ≤ n ≤ 500, 0 ≤ m ≤ 5000).

Each of the next m lines contains two integers a and b (1 ≤ a, b ≤ n, a ≠ b): team a finished above team b. The same note may appear more than once.

The notes are not guaranteed to compare every pair of teams, and some teams may not appear in any note.

### Output

- If no ranking is possible, print CONTRADICTION.
- If exactly one ranking fits, print UNIQUE, and on the next line print the ranking from first place to last, separated by spaces.
- Otherwise, print MULTIPLE.

If the notes contradict each other, print CONTRADICTION even if some teams are also left unconstrained.

### Examples

**Sample input 1**

```
4 4
3 1
1 4
4 2
3 4
```

**Sample output 1**

```
UNIQUE
3 1 4 2

```

**Explanation:** Teams 3 and 2 never appear in the same note, yet only one leaderboard agrees with all four notes: 3, 1, 4, 2.

**Sample input 2**

```
3 1
1 2
```

**Sample output 2**

```
MULTIPLE
```

**Explanation:** Team 3 appears in no note, so nothing says where it should go. The leaderboards 1 2 3, 1 3 2 and 3 1 2 all agree with the only note. Missing information never makes a leaderboard impossible; it only leaves more than one option.

**Sample input 3**

```
3 3
1 2
2 3
3 1
```

**Sample output 3**

```
CONTRADICTION

```

**Explanation:** No leaderboard can satisfy all three notes at once: whichever team is placed first, some note says another team finished above it.

**Sample input 4**

```
5 3
2 1
1 5
3 4
```

**Sample output 4**

```
MULTIPLE
```

**Explanation:** Every team appears in at least one note, but the notes still don't settle the order. For example, both 2 1 5 3 4 and 3 2 4 1 5 agree with all three notes.
