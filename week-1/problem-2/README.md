# Problem Title

- **Platform:** LeetCode
- **Problem URL:** [https://leetcode.com/problems/is-subsequence/description/?envType=problem-list-v2&envId=dynamic-programming]

## Problem Summary

Given two strings s and t, determine whether s is a subsequence of t. The relative order of characters in s must be preserved, but the characters do not need to be adjacent.

## Approach

Use the Two Pointers technique. Traverse string t while keeping track of the current character required from string s. Whenever the characters match, move the pointer of s forward.

## Algorithm

1. Initialize a pointer i = 0 for string s.

2. Traverse string t from left to right.

3. If s[i] matches the current character of t, increment i.

4. Continue until t is fully traversed or all characters of s are matched.

5. Return true if all characters of s have been matched; otherwise, return false.

## Complexity

- **Time Complexity:** O(n), where n is the length of string t.
- **Space Complexity:** O(1), using only a single pointer.

## Notes

. If s is empty, it is always a subsequence of t.
. If s is longer than t, it cannot be a subsequence.
. The characters in s must appear in the same relative order as in t.
. The matching characters do not need to be adjacent.
. An alternative approach is Dynamic Programming, but the Two Pointers technique is more space-efficient for this problem.
