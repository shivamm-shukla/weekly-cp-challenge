# Min Path Sum

- **Platform:** LeetCode
- **Problem URL:** [https://leetcode.com/problems/minimum-path-sum/?envType=problem-list-v2&envId=dynamic-programming]

## Problem Summary

Given an `m x n` grid filled with non-negative numbers, find a path from top-left `(0, 0)` to bottom-right `(m - 1, n - 1)` which minimizes the sum of all numbers along its path.

At each step, we can only move either down or right.

## Approach

At each position `(i, j)`, we have two options to reach it:
1. Move down from the cell above `(i - 1, j)`
2. Move right from the cell to the left `(i, j - 1)`

Exploring all paths recursively would result in exponential time complexity due to overlapping subproblems. Therefore, we use Dynamic Programming to store the minimum path sum to reach each cell so we don't recompute results.

We define a 2D table `dp[m][n]`, where `dp[i][j]` is the minimum path sum to reach `(i, j)`:
- Base case: `dp[0][0] = grid[0][0]`
- State transition: `dp[i][j] = grid[i][j] + min(dp[i - 1][j], dp[i][j - 1])`
(handling boundaries when `i = 0` or `j = 0`).

## Algorithm

1. Create a 2D array `dp` of size `m x n`.
2. Set `dp[0][0] = grid[0][0]` as the starting point.
3. Iterate through each cell `(i, j)` row by row:
   - If `i == 0` and `j == 0`, `dp[0][0]` is already initialized.
   - Find the cost coming from the left: `dp[i][j - 1]` if `j > 0`, else `Integer.MAX_VALUE`.
   - Find the cost coming from above: `dp[i - 1][j]` if `i > 0`, else `Integer.MAX_VALUE`.
   - Set `dp[i][j] = grid[i][j] + Math.min(left, up)`.
4. Return `dp[m - 1][n - 1]`, which contains the minimum path sum to the bottom-right corner.

## Complexity

- **Time Complexity:** O(m * n)
  We visit every cell in the grid once, doing constant work at each step.
- **Space Complexity:** O(m * n)
  We use an `m x n` 2D array `dp` to store the minimum path sums.

## Notes

. If the grid has size 1x1, the answer is just `grid[0][0]`.
. Cells in the first row can only be reached from the left, and cells in the first column can only be reached from above.
. Space complexity can be optimized to O(n) using a 1D array since we only need the previous row's results.
. We could also modify the input grid in-place to achieve O(1) extra space if permitted.
