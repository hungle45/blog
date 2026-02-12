---
date: '2026-02-12T10:27:07+07:00'
draft: false
title: 'Leetcode 3713: Longest Balanced Substring I'
showToc: false
tags: ['hash-table', 'counting', 'enumeration']
---

{{< leetcode url="https://leetcode.com/problems/longest-balanced-substring-i" id="3713" title="Longest Balanced Substring I" difficulty="Medium" >}}

### Approach: Brute-Force Enumeration + Frequency Counting

#### Intuition

The goal is to indentify the longest balanced substring within string `s`. A substring is called **balanced** if all the distinct characters in the substring appears the same number of times. My approach exhaustively explores all possible substrings to track the maximum length encountered.

Specifically:

- We utilize two nested loops with iterators `i` and `j` to traverse all possible substrings, where `i ≤ j < n`.
- While extending the right endpoint, we maintain a frequency table `cnt` to track character occurences. Since the character set is limited to lowercase English letters, a fixed-size array of length 26 is used, where the index corresponds to the character's alphabetical order.
- In each substring, we iterater throught `cnt` and check whether all characters in substring appears the same number of time. If condition is met, we update the our maximum length.

#### Implementation

```python
class Solution:
    def longestBalanced(self, s: str) -> int:

        # Helper to verify if all present characters have identical frequencies
        def check(cnt: List[int]) -> bool:
            first_freq = -1
            for freq in cnt:
                if freq == 0:
                    continue
                if first_freq == -1:
                    first_freq = freq
                elif freq != first_freq:
                    return False
            return True

        n = len(s)
        max_len = 0
        for i in range(n):
            cnt = [0] * 26
            for j in range(i, n):
                # Update frequency of the current character
                cnt[ord(s[j]) - ord('a')] += 1
                
                # Update answer if the current window satisfies the criteria
                if check(cnt):
                    max_len = max(max_len, j - i + 1)
        return max_len
```

#### Complexity Analysis

- Time complexity: $O(Cn^2)$. We iterate through all possible substrings, which takes $O(n^2)$ time. In each iteration, we perform a check operation which takes $O(C)$ time.
- Space complexity: $O(C)$. We only use a constant amount of extra space to store the counts of each character.
