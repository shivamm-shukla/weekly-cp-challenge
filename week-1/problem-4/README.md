# Vacation

- **Platform:** AtCoder
- **Problem URL:** [https://atcoder.jp/contests/dp/tasks/dp_c]

## Problem Summary

Taro's summer vacation lasts for N days. For each day, there are three activities to choose from:
- Activity A with happiness points `a`
- Activity B with happiness points `b`
- Activity C with happiness points `c`

Taro cannot choose the same activity on two or more consecutive days. We need to find the maximum total happiness points Taro can obtain over the N days.

## Approach

On each day, Taro must choose an activity different from the one he chose the previous day.

We can solve this problem using Dynamic Programming:
- If Taro chooses activity A on day `i`, on day `i - 1` he must have chosen activity B or C.
- If Taro chooses activity B on day `i`, on day `i - 1` he must have chosen activity A or C.
- If Taro chooses activity C on day `i`, on day `i - 1` he must have chosen activity A or B.

Let `dpA`, `dpB`, and `dpC` represent the maximum happiness accumulated up to the previous day ending with activity A, B, or C respectively.

For the current day:
- `newA = a + max(dpB, dpC)`
- `newB = b + max(dpA, dpC)`
- `newC = c + max(dpA, dpB)`

Since each day's calculations only depend on the previous day, we don't need an `N x 3` table and can maintain just three variables, optimizing space complexity to O(1).

## Algorithm

1. Initialize three variables `dpA = 0`, `dpB = 0`, and `dpC = 0`.
2. Loop through each day from 1 to N:
   - Read happiness values `a`, `b`, and `c` for the current day.
   - Calculate `newA = a + Math.max(dpB, dpC)`.
   - Calculate `newB = b + Math.max(dpA, dpC)`.
   - Calculate `newC = c + Math.max(dpA, dpB)`.
   - Update `dpA = newA`, `dpB = newB`, and `dpC = newC`.
3. After iterating through all N days, return `Math.max(dpA, Math.max(dpB, dpC))`.

## Complexity

- **Time Complexity:** O(N)
  We iterate through the N days once, performing a constant number of comparisons and additions per day.
- **Space Complexity:** O(1)
  We only keep three state variables (`dpA`, `dpB`, `dpC`) instead of storing the entire DP table.

## Notes

. Taro cannot perform the same activity on two consecutive days.
. Storing only the previous day's three DP states reduces space from O(N) to O(1).
. If N = 1, the result is simply the maximum happiness among the three activities for that single day.
