# Problem Title

- **Platform:** AtCoder
- **Problem URL:** [https://atcoder.jp/contests/dp/tasks/dp_a]

## Problem Summary

In this problem, I have to move a frog from Stone 1 to Stone N.

The frog can jump either 1 stone or 2 stones at a time.

The cost of jumping from one stone to another is the absolute difference between their heights.

I have to find the minimum total cost required to reach the last stone.

## Approach

At first, I thought about trying all possible paths, but that would take too much time because the number of paths can grow exponentially.

So, I decided to use Dynamic Programming.

I will store the minimum cost required to reach each stone in a dp array.

For reaching the current stone, I only have two possible options:

    1. Jump from the previous stone.
    2. Jump from two stones back.

I will calculate the cost of both options and choose the minimum one.

## Algorithm

1. I will create a dp array of size N.
2. I will set dp[0] = 0 because I am already at the first stone.
3. I will run a loop from the second stone to the last stone.
4. For each stone, I will calculate the cost of reaching it from the previous stone.
5. If I can jump from two stones back, I will calculate that cost as well.
6. I will store the minimum of these two costs in dp[i].
7. Finally, I will return dp[N - 1].

## Complexity
- **Time Complexity:** O(N)
    I am travelling the stones only once, and doing constant work for each stone
- **Space Complexity:** O(N)
    I am using a dp array of size N to store the minimum cost for every stone.

## Notes
. If N = 1, the answer will be 0 bcoz I am already at the destination.
. I only need to check the previous two stones bcoz the frog can jumpt at most 2 stones.
. I can also optimize the space to O(1) by storing only the previous two dp values instead of the entire array.

